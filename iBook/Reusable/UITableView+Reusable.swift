//
//  UITableView+Reusable.swift
//  fideo
//
//  Created by Jovins on 2019/8/15.
//  Copyright © 2019 hanron. All rights reserved.
//

import UIKit

// MARK: Reusable support for UITableView
extension UITableView {
    
    /**
     Register a NIB-Based `UITableViewCell` subclass (conforming to `Reusable` & `NibLoadable`)
     
     - parameter cellType: the `UITableViewCell` (`Reusable` & `NibLoadable`-conforming) subclass to register
     
     - eg: `register(_:,forCellReuseIdentifier:)`
     */
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable & NibLoadable {
        
        self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Register a Class-Based `UITableViewCell` subclass (conforming to `Reusable`)
     
     - parameter cellType: the `UITableViewCell` (`Reusable`-conforming) subclass to register
     
     - eg: `register(_:,forCellReuseIdentifier:)`
     */
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable {
        
        self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Returns a reusable `UITableViewCell` object for the class inferred by the return-type
     
     - parameter indexPath: The index path specifying the location of the cell.
     - parameter cellType: The cell class to dequeue
     
     - returns: A `Reusable`, `UITableViewCell` instance
     
     - note: The `cellType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - eg: `dequeueReusableCell(withIdentifier:,for:)`
     */
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T where T: Reusable {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
    
    // MARK: - UITableViewHeaderFooterView
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) where T: Reusable & NibLoadable {
        
        self.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) where T: Reusable {
        
        self.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T? where T: Reusable {
        
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
            
            fatalError(
                "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
                    + "matching type \(viewType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the header/footer beforehand"
            )
        }
        return view
    }
}
