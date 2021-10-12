//
//  BaseTabbarViewController.swift
//  PDFDemo
//
//  Created by Jovins on 2021/10/5.
//

import UIKit

class BaseTabBar: UITabBar {
    
}

class BaseTabBarController: UITabBarController {
    
    enum Tabs {
        case book
        case history
        
        var selectedImage: UIImage {
            switch self {
            case .book:
                return UIImage(systemName: "book.fill")!.withRenderingMode(.alwaysOriginal)
            case .history:
                return UIImage(systemName: "doc.fill")!.withRenderingMode(.alwaysOriginal)
            }
        }
        
        var unselectedImage: UIImage {
            switch self {
            case .book:
                return UIImage(systemName: "book")!.withRenderingMode(.alwaysOriginal)
            case .history:
                return UIImage(systemName: "doc")!.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    /// 初始化
    static func tabBarController() -> BaseTabBarController {
        let tabBarController = BaseTabBarController()
        return tabBarController
    }
    
    lazy var customTabBar: BaseTabBar = {
        let tabBar = BaseTabBar(frame: self.tabBar.frame)
        return tabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(customTabBar)
        setValue(customTabBar, forKey: "tabBar")
        
        let bookVC = BookListViewController()
        let bookNaVC = UINavigationController(rootViewController: bookVC)
        bookVC.tabBarItem = UITabBarItem(title: "书库", image: Tabs.book.unselectedImage, selectedImage: Tabs.book.selectedImage)
        
        let historyVC = HistoryViewController()
        let historyNaVC = UINavigationController(rootViewController: historyVC)
        historyVC.tabBarItem = UITabBarItem(title: "历史", image: Tabs.history.unselectedImage, selectedImage: Tabs.history.selectedImage)
        viewControllers = [bookNaVC, historyNaVC]
        tabBar.isTranslucent = false
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        if let items = tabBar.items {
            for (index, item) in items.enumerated() {
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                item.tag = index
            }
        }
    }
}
