//
//  WindowViewController.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

final class WindowViewController: UIViewController {
    
    var window: UIWindow?
    init() {
        let view = BurstThroughView()
        let window = BurstThroughWindow(hitBustView: view)
        self.window = window
        super.init(nibName: nil, bundle: nil)
        self.view = view
        window.rootViewController = self
    }
    
    func install() {
        guard let window = self.window else {
            return
        }
        window.frame = UIScreen.main.bounds
        window.isHidden = false
        if #available(iOS 13, *) {
            let activeScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            window.windowScene = activeScene
        }
    }
    
    func uninstall() {
        guard let window = self.window else {
            return
        }
        window.isHidden = true
        if #available(iOS 13, *) {
            window.windowScene = nil
        }
        self.window = nil
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}
