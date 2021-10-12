//
//  UIColor+Ex.swift
//  PDFDemo
//
//  Created by Jovins on 2021/10/7.
//

import UIKit

extension UIColor {
    
    /// Init color with hex code
    /// - Parameter value: hex code (eg. 0x003300)
    /// - Returns: UIColor
    convenience init(hex: UInt32) {
        self.init(
            CGFloat((hex & 0xFF0000) >> 16),    // red
            CGFloat((hex & 0xFF00) >> 8),       // green
            CGFloat((hex & 0xFF))               // blue
        )
    }
    
    convenience init(_ r256: CGFloat, _ g256: CGFloat, _ b256: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r256 / 255.0, green: g256 / 255.0, blue: b256 / 255.0, alpha: alpha)
    }
}
