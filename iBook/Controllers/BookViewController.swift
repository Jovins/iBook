//
//  BookViewController.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit
import PDFKit
import SnapKit
import Hero

class BookViewController: UIViewController {
    
    // MARK: - Property
    var model: DocumentModel? {
        didSet {
            guard let model = self.model, let url = model.url else { return }
            self.document = PDFDocument(url: url)
        }
    }
    private var document: PDFDocument?
    private let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    private let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    private let toggleSegmentedControl = UISegmentedControl(items: [UIImage(named: "Grid")!, UIImage(named: "List")!, UIImage(named: "Bookmark-N")!])
    private var bookmarkButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizedToggleVisibility(_:)))
        self.pdfView.addGestureRecognizer(barHideOnTapGestureRecognizer)
        
        setupUI()
        setupData()
        resume()
        
        // 处理收藏
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
        
        self.toggleSegmentedControl.selectedSegmentIndex = 0
        self.toggleSegmentedControl.addTarget(self, action: #selector(toggleChangeContentView(_:)), for: .valueChanged)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        storgeCurrentPage()
        storgeHistoryList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupUI() {
        
        let bounds = CGRect(x: 0, y: Device.navBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Device.navBarHeight)
        self.view.addSubview(self.thumbnailGridViewConainer)
        self.thumbnailGridViewConainer.frame = self.view.bounds
        let gridVC = ThumbnailGridViewController()
        self.thumbnailGridViewConainer.addSubview(gridVC.view)
        gridVC.view.frame = bounds
        self.addChild(gridVC)
        gridVC.document = self.document
        gridVC.delegate = self
        
        self.view.addSubview(outlineViewConainer)
        self.outlineViewConainer.frame = self.view.bounds
        let outlineVC = OutlineViewController()
        self.outlineViewConainer.addSubview(outlineVC.view)
        outlineVC.view.frame = bounds
        self.addChild(outlineVC)
        outlineVC.document = self.document
        outlineVC.delegate = self
        
        self.view.addSubview(self.bookmarkViewConainer)
        self.bookmarkViewConainer.frame = self.view.bounds
        let markVC = BookmarkViewController()
        self.bookmarkViewConainer.addSubview(markVC.view)
        markVC.view.frame = bounds
        self.addChild(markVC)
        markVC.document = self.document
        markVC.delegate = self
        
        self.view.addSubview(self.pdfView)
        self.pdfView.frame = UIScreen.main.bounds
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Device.navBarHeight + 16)
        }
        
        self.view.addSubview(self.pdfThumbnailViewContainer)
        self.pdfThumbnailViewContainer.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(Device.tabBarHeight)
        }
        self.pdfThumbnailViewContainer.addSubview(self.pdfThumbnailView)
        self.pdfThumbnailView.frame = CGRect(x: 0, y: 0, width: Device.kWidth, height: 44)
        
        self.view.addSubview(self.pageNumberLabel)
        self.pageNumberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.pdfThumbnailViewContainer.snp.top).offset(-16)
        }
    }
    
    private func setupData() {
        
        self.pdfView.addGestureRecognizer(self.pdfViewGestureRecognizer)
        self.pdfView.document = self.document
        self.pdfThumbnailView.layoutMode = .horizontal
        self.pdfThumbnailView.pdfView = self.pdfView
        self.titleLabel.text = self.document?.documentAttributes?["Title"] as? String
        
        /// 跳到之前浏览的页面
        if let documentURL = self.document?.documentURL?.absoluteString {
            
            let key = documentURL.appending("/storgeCurrentPage")
            let index = UserDefaults.standard.integer(forKey: key)
            if let page = self.document?.page(at: index) {
                self.pdfView.go(to: page)
            }
        }
    }
    
    // MARK: - @objc
    @objc
    private func backBtnAction() {
        // self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if let navigationController = navigationController {
            if navigationController.navigationBar.alpha > 0 {
                hideBars()
            } else {
                showBars()
            }
        }
    }
    
    @objc
    func showTableOfContents(_ sender: UIBarButtonItem) {
        showTableOfContents()
    }
    
    @objc
    func showActionMenu(_ sender: UIBarButtonItem) {
        
        let printInteractionController = UIPrintInteractionController.shared
        printInteractionController.printingItem = self.document?.dataRepresentation()
        printInteractionController.present(animated: true, completionHandler: nil)
    }
    
    @objc
    func showSearchView(_ sender: UIBarButtonItem) {
        
        let searchVC = SearchViewController()
        searchVC.document = self.document
        searchVC.delegate = self
        let navVC = UINavigationController(rootViewController: searchVC)
        navVC.modalPresentationStyle = .fullScreen
        Hero.shared.containerColor = .clear
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        self.present(navVC, animated: true, completion: nil)
    }
    
    /// 收藏
    @objc
    func addOrRemoveBookmark(_ sender: UIBarButtonItem) {
        
        if let documentURL = self.document?.documentURL?.absoluteString {
            var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [
            Int] ?? [Int]()
            if let currentPage = self.pdfView.currentPage, let pageIndex = self.document?.index(for: currentPage) {
                // 移除
                if let index = bookmarks.firstIndex(of: pageIndex) {
                    bookmarks.remove(at: index)
                    UserDefaults.standard.set(bookmarks, forKey: documentURL)
                    self.bookmarkButton?.image = UIImage(named: "Bookmark-N")
                } else { // 收藏
                    UserDefaults.standard.set((bookmarks + [pageIndex]).sorted(), forKey: documentURL)
                    self.bookmarkButton?.image = UIImage(named: "Bookmark-P")
                }
            }
        }
    }
    
    @objc
    func pdfViewPageChanged(_ notification: Notification) {
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updateBookmarkStatus()
        updatePageNumberLabel()
    }
    
    @objc
    func toggleChangeContentView(_ sender: UISegmentedControl) {
        
        self.pdfView.isHidden = true
        self.titleLabel.alpha = 0
        self.pageNumberLabel.alpha = 0
        
        if self.toggleSegmentedControl.selectedSegmentIndex == 0 {
            self.thumbnailGridViewConainer.isHidden = false
            self.outlineViewConainer.isHidden = true
            self.bookmarkViewConainer.isHidden = true
        } else if self.toggleSegmentedControl.selectedSegmentIndex == 1 {
            self.thumbnailGridViewConainer.isHidden = true
            self.outlineViewConainer.isHidden = false
            self.bookmarkViewConainer.isHidden = true
        } else {
            self.thumbnailGridViewConainer.isHidden = true
            self.outlineViewConainer.isHidden = true
            self.bookmarkViewConainer.isHidden = false
        }
    }
    
    @objc
    func resume(_ sender: UIBarButtonItem) {
        resume()
    }
    
    // MARK: - Funcs
    private func resume() {
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backBtnAction))
        let contensButton = UIBarButtonItem(image: UIImage(named: "List"), style: .plain, target: self, action: #selector(showTableOfContents(_:)))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionMenu(_:)))
        self.navigationItem.leftBarButtonItems = [backButton, contensButton, actionButton]
        
        let searchButton = UIBarButtonItem(image: UIImage(named: "Search"), style: .plain, target: self, action: #selector(showSearchView(_:)))
        let bookmark = UIBarButtonItem(image: UIImage(named: "Bookmark-N"), style: .plain, target: self, action: #selector(addOrRemoveBookmark(_:)))
        self.bookmarkButton = bookmark
        self.navigationItem.rightBarButtonItems = [searchButton, bookmark]
        
        self.pdfView.isHidden = false
        self.pdfThumbnailViewContainer.alpha = 1
        self.titleLabel.alpha = 1
        self.pageNumberLabel.alpha = 1
        self.thumbnailGridViewConainer.isHidden = true
        self.outlineViewConainer.isHidden = true
        self.bookmarkViewConainer.isHidden = true
        
        barHideOnTapGestureRecognizer.isEnabled = true
        updateBookmarkStatus()
        updatePageNumberLabel()
    }
    
    private func showTableOfContents() {
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backBtnAction))
        let toggleButton = UIBarButtonItem(customView: toggleSegmentedControl)
        let resumeBarButton = UIBarButtonItem(title: NSLocalizedString("续读", comment: ""), style: .plain, target: self, action: #selector(resume(_:)))
        navigationItem.leftBarButtonItems = [backButton, toggleButton]
        navigationItem.rightBarButtonItems = [resumeBarButton]
        
        self.pdfThumbnailViewContainer.alpha = 0
        toggleChangeContentView(toggleSegmentedControl)
        self.barHideOnTapGestureRecognizer.isEnabled = false
    }
    
    private func updateBookmarkStatus() {
        
        if let documentURL = self.document?.documentURL?.absoluteString,
            let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage,
            let index = self.document?.index(for: currentPage) {
            self.bookmarkButton?.image = bookmarks.contains(index) ? UIImage(named: "Bookmark-P") : UIImage(named: "Bookmark-N")
        }
    }
    
    private func updatePageNumberLabel() {
        
        if let currentPage = pdfView.currentPage, let index = self.document?.index(for: currentPage), let pageCount = self.document?.pageCount {
            self.pageNumberLabel.text = String(format: "%d/%d", index + 1, pageCount)
        } else {
            self.pageNumberLabel.text = nil
        }
    }
    
    private func showBars() {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 1
                self.pdfThumbnailViewContainer.alpha = 1
                self.titleLabel.alpha = 1
                self.pageNumberLabel.alpha = 1
            }
        }
    }

    private func hideBars() {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 0
                self.pdfThumbnailViewContainer.alpha = 0
                self.titleLabel.alpha = 0
                self.pageNumberLabel.alpha = 0
            }
        }
    }
    
    // 存储浏览历史记录
    private func storgeHistoryList() {
        
        if let documentURL = self.document?.documentURL?.absoluteString {
            
            let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].absoluteString
            let key = cache.appending("com.jovins.ibook.storgeHistory")
            if var documentURLs = UserDefaults.standard.array(forKey: key) as? [String] {
                
                if !documentURLs.contains(documentURL) {
                    // 不存在则存储
                    documentURLs.append(documentURL)
                    UserDefaults.standard.set(documentURLs, forKey: key)
                }
            } else {
                // 第一次存储
                UserDefaults.standard.set([documentURL], forKey: key)
            }
        }
    }
    
    /// 存储当前浏览第几页
    private func storgeCurrentPage() {
        
        if let documentURL = self.document?.documentURL?.absoluteString {
            
            let key = documentURL.appending("/storgeCurrentPage")
            if let currentPage = self.pdfView.currentPage, let index = self.document?.index(for: currentPage) {
                UserDefaults.standard.set(index, forKey: key)
            }
        }
    }
    
    // MARK: - Lazy
    fileprivate lazy var thumbnailGridViewConainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var outlineViewConainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var bookmarkViewConainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var pdfView: PDFView = {
        
        let view = PDFView()
        view.backgroundColor = Device.bgColor
        view.autoScales = true
        view.displayMode = .singlePage
        view.displayDirection = .horizontal
        view.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.spineLocation: 20])
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pdfThumbnailViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var pdfThumbnailView: PDFThumbnailView = {
        let view = PDFThumbnailView()
        view.backgroundColor = .white
        return view
    }()
}


// MARK: - PDFViewGestureRecognizer
class PDFViewGestureRecognizer: UIGestureRecognizer {
    
    var isTracking = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}

// MARK: - ThumbnailGridViewControllerDelegate
extension BookViewController: ThumbnailGridViewControllerDelegate {
    
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        
        resume()
        pdfView.go(to: page)
    }
}

// MARK: - OutlineViewControllerDelegate
extension BookViewController: OutlineViewControllerDelegate {
    
    func outlineViewController(_ outlineViewController: OutlineViewController, didSelectOutlineAt destination: PDFDestination) {
        resume()
        pdfView.go(to: destination)
    }
}

// MARK: - BookmarkViewControllerDelegate
extension BookViewController: BookmarkViewControllerDelegate {
    
    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectPage page: PDFPage) {
        resume()
        pdfView.go(to: page)
    }
}

// MARK: -
extension BookViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult selection: PDFSelection) {
        
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
        showBars()
    }
}
