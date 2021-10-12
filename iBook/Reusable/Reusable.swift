//
//  Reusable.swift
//  fideo
//
//  Created by Jovins on 2019/8/15.
//  Copyright © 2019 hanron. All rights reserved.
//

import UIKit

/// Make your `UITableViewCell` and `UICollectionViewCell` subclasses
protocol Reusable: AnyObject {
    
    static var reuseIdentifier: String { get }
}

typealias NibReusable = Reusable & NibLoadable

// MARK: - Default implementation
extension Reusable {
    
    /// By default, use the name of the class as String for its reuseIdentifier
    static var reuseIdentifier: String {
        
        return String(describing: self)
    }
}
