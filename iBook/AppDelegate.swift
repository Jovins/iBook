//
//  AppDelegate.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit
import Bursts

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let pdfs: [String] = ["Swifter.pdf", "Redis.pdf", "Shell.pdf", "JavaScriptDevelop.pdf", "Git.pdf", "NodeJS7.pdf"]
        
        let fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        for name in pdfs {
            if let sameFile = Bundle.main.url(forResource: name, withExtension: nil) {
                let destination = cachesDirectory.appendingPathComponent(name)
                if !fileManager.fileExists(atPath: destination.path) {
                    try? fileManager.copyItem(at: sameFile, to: destination)
                }
            }
        }
        
        /// 外部打开一个pdf文件
        if let launchOptions = launchOptions, let url = launchOptions[.url] as? URL {
            let destination = cachesDirectory.appendingPathComponent(url.lastPathComponent)
            if !fileManager.fileExists(atPath: destination.path) {
                try! fileManager.copyItem(at: url, to: destination)
                NotificationCenter.default.post(name: .cacheDirectoryDidChange, object: nil)
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destination = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        if !fileManager.fileExists(atPath: destination.path) {
            
            try? fileManager.copyItem(at: url, to: destination)
            NotificationCenter.default.post(name: .cacheDirectoryDidOpen, object: nil)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

