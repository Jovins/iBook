//
//  NibOwnerLoadable.swift
//  fideo
//
//  Created by Jovins on 2019/8/15.
//  Copyright © 2019 hanron. All rights reserved.
//

import UIKit

// MARK: Protocol Definition 定义
/// Make your UIView subclasses conform to this protocol when:
///  * they *are* NIB-based, and
///  * this class is used as the XIB's File's Owner
///
/// to be able to instantiate them from the NIB in a type-safe manner
protocol NibOwnerLoadable: AnyObject {
    
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib { get }
}

// MARK: Default implementation 实现
/// By default, use the nib which have the same name as the name of the class,
/// and located in the bundle of that class
extension NibOwnerLoadable {
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: Support for instantiation from NIB
extension NibOwnerLoadable where Self: UIView {
    
    func loadNibContent() {
        
        let layoutAttributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
        for case let view as UIView in Self.nib.instantiate(withOwner: self, options: nil) {
            
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            NSLayoutConstraint.activate(layoutAttributes.map { attribute in
                
                NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal,
                                   toItem: self, attribute: attribute, multiplier: 1, constant: 0)
            })
        }
    }
}

/// Swift < 4.2 support
#if !(swift(>=4.2))

private extension NSLayoutConstraint {
    
    typealias Attribute = NSLayoutConstraint.Attribute
}

#endif
