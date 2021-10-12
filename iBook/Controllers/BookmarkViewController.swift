//
//  BookmarkViewController.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit
import PDFKit
import DZNEmptyDataSet

class BookmarkViewController: UIViewController {
    
    var document: PDFDocument? {
        didSet {
            if let _ = document {
                self.refreshData()
            }
        }
    }
    
    weak var delegate: BookmarkViewControllerDelegate?
    private let thumbnailCache = NSCache<NSNumber, UIImage>()
    private let downloadQueue = DispatchQueue(label: "com.jovins.pdfview.thumbnail")
    fileprivate var bookmarks: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(collection)
        collection.frame = self.view.bounds
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func refreshData() {
        
        if let documentURL = self.document?.documentURL?.absoluteString, let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] {
            self.bookmarks = bookmarks
            self.collection.reloadData()
        }
    }
    
    @objc
    func userDefaultsDidChange(_ notification: Notification) {
        refreshData()
    }
    
    // MARK: - Lazy
    private lazy var layout: UICollectionViewFlowLayout = {
        let lay = UICollectionViewFlowLayout()
        lay.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16 * 4)/3, height: 140)
        lay.minimumInteritemSpacing = 16
        lay.minimumLineSpacing = 16
        return lay
    }()
    
    fileprivate lazy var collection: UICollectionView = {
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collection.backgroundColor = Device.bgColor
        collection.register(cellType: GridCell.self)
        collection.delegate = self
        collection.dataSource = self
        collection.emptyDataSetSource = self
        collection.emptyDataSetDelegate = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
}

extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bookmarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: GridCell.self)
        
        let pageNumber = self.bookmarks[indexPath.item]
        if let page = self.document?.page(at: pageNumber) {
            cell.pageNumber = pageNumber
            let key = NSNumber(value: pageNumber)
            if let thumbnail = self.thumbnailCache.object(forKey: key) {
                cell.image = thumbnail
            } else {
                let cellSize = CGSize(width: (UIScreen.main.bounds.width - 16 * 4)/3, height: 140)
                downloadQueue.async {
                    let thumbnail = page.thumbnail(of: cellSize, for: .cropBox)
                    self.thumbnailCache.setObject(thumbnail, forKey: key)
                    if cell.pageNumber == pageNumber {
                        DispatchQueue.main.async {
                            cell.image = thumbnail
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        GeneratorManager.shared.impactFeedBack(.light)
        if let page = self.document?.page(at: self.bookmarks[indexPath.item]) {
            self.delegate?.bookmarkViewController(self, didSelectPage: page)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension BookmarkViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {

        return -44
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        return NSAttributedString(string: "暂无收藏", font: UIFont.boldSystemFont(ofSize: 18), color: UIColor.gray)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

protocol BookmarkViewControllerDelegate: AnyObject {
    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectPage page: PDFPage)
}
