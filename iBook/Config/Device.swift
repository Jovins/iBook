//
//  Device.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit

struct Device {
    
    static let kApplication = UIApplication.shared
    static let kMainScreen = UIScreen.main
    static let kDevice = UIDevice.current
    
    static let isPortrait = Device.kApplication.statusBarOrientation.isPortrait
    static let kHeight: CGFloat = Device.isPortrait ? Device.kMainScreen.bounds.size.height : Device.kMainScreen.bounds.size.width
    static let kWidth: CGFloat = Device.isPortrait ? Device.kMainScreen.bounds.size.width : Device.kMainScreen.bounds.size.height
    
    static let isIphoneX: Bool = Device.kHeight >= 812 ? true : false
    /// 83/49
    static let tabBarHeight: CGFloat = Device.isIphoneX ? 83 : 49 // 这里只考虑竖屏
    /// 88/64
    static let navBarHeight: CGFloat = Device.isIphoneX ? 88 : 64
    /// 44/20
    static let statusBar: CGFloat = Device.isIphoneX ? 44 : 20
    /// 44
    static let navBar: CGFloat = 44
    /// 34/0
    static let safeTabBar: CGFloat = Device.isIphoneX ? 34 : 0
    
    static let bgColor: UIColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
    
    static let tintColor: UIColor = UIColor(hex: 0x1E90FF)
}
