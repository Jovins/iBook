//
//  BooksViewController.swift
//  PDFDemo
//
//  Created by Jovins on 2021/10/5.
//

import UIKit
import PDFKit

class BookListViewController: UIViewController {

    var models: [DocumentModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "书库"
        view.backgroundColor = .white
        view.addSubview(collection)
        collection.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 88)
        
        refreshData()
        NotificationCenter.default.addObserver(self, selector: #selector(cacheDirectoryDidChange(_:)), name: .cacheDirectoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cacheDirectoryDidOpenPDF(_:)), name: .cacheDirectoryDidOpen, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func refreshData() {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            
            let urls = contents.filter { $0.absoluteString.contains(".pdf") }
            self.models = urls.compactMap { BookManager.shared.getDocument(PDFDocument(url: $0)) }
            self.collection.reloadData()
        }
    }
    
    @objc
    func cacheDirectoryDidChange(_ notification: Notification) {
        
        refreshData()
    }
    
    @objc
    func cacheDirectoryDidOpenPDF(_ notification: Notification) {
        
        refreshData()
        if let url = notification.object as? URL {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                let bookVC = BookViewController()
                bookVC.model = BookManager.shared.getDocument(PDFDocument(url: url))
                let nav = UINavigationController(rootViewController: bookVC)
                nav.modalPresentationStyle = .fullScreen
                nav.hero.isEnabled = true
                nav.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .push(direction: .right))
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Lazy
    private lazy var layout: UICollectionViewFlowLayout = {
        let lay = UICollectionViewFlowLayout()
        lay.itemSize = CGSize(width: (UIScreen.main.bounds.width - 48)/2, height: 240)
        lay.minimumInteritemSpacing = 16
        lay.minimumLineSpacing = 16
        return lay
    }()
    
    fileprivate lazy var collection: UICollectionView = {
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collection.backgroundColor = Device.bgColor
        collection.register(cellType: BooksCell.self)
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
}

extension BookListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BooksCell.self)
        
        let model = self.models[indexPath.item]
        cell.title = model.title
        cell.image = model.coverImage
        
        return cell
    }
}

extension BookListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        GeneratorManager.shared.impactFeedBack(.light)
        if let cell = collectionView.cellForItem(at: indexPath) as? BooksCell {

            let bookVC = BookViewController()
            bookVC.model = self.models[indexPath.item]
            cell.hero.id = "BooksCell\(indexPath.item)"
            bookVC.pdfView.hero.id = "BooksCell\(indexPath.item)"
            let nav = UINavigationController(rootViewController: bookVC)
            nav.modalPresentationStyle = .fullScreen
            nav.hero.isEnabled = true
            self.present(nav, animated: true, completion: nil)
        }
    }
}
