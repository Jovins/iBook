//
//  OutlineViewController.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit
import PDFKit

protocol OutlineViewControllerDelegate: AnyObject {
    
    func outlineViewController(_ outlineViewController: OutlineViewController, didSelectOutlineAt destination: PDFDestination)
}

class OutlineViewController: UIViewController {
    
    var document: PDFDocument?
    weak var delegate: OutlineViewControllerDelegate?
     fileprivate var lines = [PDFOutline]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadDataLines()
        }
    }
    
    private func reloadDataLines() {
        if let root = self.document?.outlineRoot {
            var stack = [root]
            while !stack.isEmpty {
                let current = stack.removeLast()
                if let label = current.label, !label.isEmpty {
                    self.lines.append(current)
                }
                for i in (0..<current.numberOfChildren).reversed() {
                    if let child = current.child(at: i) {
                        stack.append(child)
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        tableView.separatorColor = UIColor(hex: 0xefefef)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 4)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.register(cellType: OutlineCell.self)
        return tableView
    }()
}

extension OutlineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OutlineCell.self)

        let outline = self.lines[indexPath.item]
        cell.titleString = outline.label
        cell.pageString = outline.destination?.page?.label
        
        var indentationLevel = -1
        var parent = outline.parent
        while let _ = parent {
            indentationLevel += 1
            parent = parent?.parent
        }
        cell.indentationLevel = indentationLevel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        GeneratorManager.shared.impactFeedBack(.light)
        let outline = self.lines[indexPath.item]
        if let destination = outline.destination {
            self.delegate?.outlineViewController(self, didSelectOutlineAt: destination)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
