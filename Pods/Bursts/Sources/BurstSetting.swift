//
//  BurstSetting.swift
//  Bursts
//
//  Created by Jovins on 2021/7/20.
//

import UIKit

public struct BurstSetting {
    
    /// 是否是默认
    public var isDefault: Bool = true
    /// 背景颜色, eg: .white
    public var backgroundColor: UIColor = UIColor.white
    /// 阴影颜色, eg: .black
    public var shadowColor: UIColor = UIColor.black
    /// 字体颜色
    public var titleColor: UIColor = .black
    /// 小字体颜色
    public var subtitleColor: UIColor = .darkGray
    
    public init() {
        
    }
}
