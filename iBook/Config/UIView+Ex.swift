//
//  UIView+Ex.swift
//  PDFDemo
//
//  Created by Jovins on 2021/10/5.
//

import UIKit

extension UIView {
    
    func neumorphism(with themeColor: UIColor = UIColor.white, cornerRadius: CGFloat = 8.0, alpha: CGFloat = 1.0) {
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = false
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: -4, height: 4)
        self.layer.shadowColor = UIColor(red: 223/255, green: 228/255, blue: 238/255, alpha: 1.0).cgColor
        // 解决阴影离屏渲染问题
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        shadowLayer.backgroundColor = Device.bgColor.cgColor
        shadowLayer.shadowColor = UIColor.white.cgColor
        shadowLayer.cornerRadius = cornerRadius
        shadowLayer.shadowOffset = CGSize(width: 4, height: -4)
        shadowLayer.shadowRadius = 2
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}
