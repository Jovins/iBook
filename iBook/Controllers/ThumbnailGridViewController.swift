//
//  ThumbnailGridViewController.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit
import PDFKit

protocol ThumbnailGridViewControllerDelegate: AnyObject {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage)
}

class ThumbnailGridViewController: UIViewController {
    
    var document: PDFDocument? {
        didSet {
            if let _ = document {
                self.collection.reloadData()
            }
        }
    }
    weak var delegate: ThumbnailGridViewControllerDelegate?
    
    fileprivate let thumbnailCache = NSCache<NSNumber, UIImage>()
    private let downloadQueue = DispatchQueue(label: "com.jovins.pdfview.thumbnail")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(collection)
        collection.frame = self.view.bounds
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
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
}

extension ThumbnailGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let doc = self.document {
            return doc.pageCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: GridCell.self)
        if let doc = self.document, let page = doc.page(at: indexPath.item) {
            
            let pageNumber = indexPath.item
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
        if let page = self.document?.page(at: indexPath.item) {
            self.delegate?.thumbnailGridViewController(self, didSelectPage: page)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
