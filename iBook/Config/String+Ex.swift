//
//  String+Ex.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit

extension String {
    
    /// 计算宽度
    func width(for font: UIFont) -> CGFloat {
        return size(for: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: .byWordWrapping).width
    }
    
    /// 计算指定字体的尺寸
    ///
    /// - Parameters:
    ///   - font: 字体
    ///   - size: 区域大小
    ///   - lineBreakMode: 换行模式
    /// - Returns: 尺寸
    func size(for font: UIFont, size: CGSize, lineBreakMode: NSLineBreakMode) -> CGSize {
        var attr:[NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        if lineBreakMode != .byWordWrapping {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode
            attr[.paragraphStyle] = paragraphStyle
        }
        let rect = (self as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        return rect.size
    }
}

extension NSAttributedString {
    
    convenience init(string: String, font: UIFont, color: UIColor = UIColor.black) {
        
        self.init(string: string, attributes: [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font
            ])
    }
}
