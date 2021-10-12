//
//  UIView+Extension.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

extension UIView {
    
    var safeArea: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
}
