//
//  SearchViewController.swift
//  iBook
//
//  Created by Jovins on 2021/10/10.
//

import UIKit
import PDFKit

protocol SearchViewControllerDelegate: AnyObject {
    
    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult selection: PDFSelection)
}

class SearchViewController: UIViewController {
    
    var document: PDFDocument?
    weak var delegate: SearchViewControllerDelegate?
    fileprivate var searchResults = [PDFSelection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self
        if let textfield = self.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.cornerRadius = 18
            textfield.clipsToBounds = true
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.cancelButton)
        self.view.addSubview(tableView)
        self.tableView.frame = CGRect(x: 0, y: 0, width: Device.kWidth, height: Device.kHeight - Device.navBarHeight - 16)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    deinit {
        self.document?.cancelFindString()
        self.document?.delegate = nil
    }
    
    // MARK: - @objc
    @objc
    private func cancelButtonDidAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lazy
    fileprivate lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.showsCancelButton = false
        bar.placeholder = "输入关键字搜索"
        bar.tintColor = Device.tintColor
        bar.searchBarStyle = .minimal
        return bar
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: "取消", attributes: [.foregroundColor : Device.tintColor, .font: UIFont.boldSystemFont(ofSize: 16)]), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidAction(_:)), for: .touchUpInside)
        button.size = CGSize(width: 44, height: 44)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        tableView.separatorColor = UIColor(hex: 0xcfcfcf)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        tableView.register(cellType: SearchCell.self)
        return tableView
    }()
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchCell.self)
        
        let selection = self.searchResults[indexPath.item]
        let page = selection.pages[0]
        let outline = self.document?.outlineItem(for: selection)
        cell.sectionString = outline?.label // 目录
        cell.pageString = page.label // 页数
        
        if let extendSelection = selection.copy() as? PDFSelection {
            extendSelection.extend(atStart: 10)
            extendSelection.extend(atEnd: 90)
            extendSelection.extendForLineBoundaries()
            
            cell.resultText = extendSelection.string
            cell.searchText = selection.string
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xefefef)
        view.frame = CGRect(x: 0, y: 0, width: Device.kWidth, height: 32)
        let label = UILabel()
        label.text = "搜索结果"
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        view.addSubview(label)
        label.frame = CGRect(x: 16, y: 0, width: 120, height: 32)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selection = self.searchResults[indexPath.row]
        searchBar.resignFirstResponder()
        if self.delegate != nil {
            delegate?.searchViewController(self, didSelectSearchResult: selection)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate, PDFDocumentDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        if searchText.count < 3 {
            return
        }
        self.searchResults.removeAll()
        self.tableView.reloadData()
        if let document = self.document {
            document.cancelFindString()
            document.delegate = self
            document.beginFindString(searchText, withOptions: .caseInsensitive)
        }
    }

    /// 搜索
    func didMatchString(_ instance: PDFSelection) {
        self.searchResults.append(instance)
        self.tableView.reloadData()
    }
}
