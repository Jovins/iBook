//
//  UICollectionView+Reusable.swift
//  fideo
//
//  Created by Jovins on 2019/8/15.
//  Copyright © 2019 hanron. All rights reserved.
//

import UIKit

// MARK: Reusable support for UICollectionView
extension UICollectionView {
    
    /**
     Register a NIB-Based `UICollectionViewCell` subclass (conforming to `Reusable` & `NibLoadable`)
     
     - parameter cellType: the `UICollectionViewCell` (`Reusable` & `NibLoadable`-conforming) subclass to register
     
     - eg: `register(_:,forCellWithReuseIdentifier:)`
     */
    func register<T: UICollectionViewCell>(cellType: T.Type) where T: Reusable & NibLoadable {
        
        self.register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Register a Class-Based `UICollectionViewCell` subclass (conforming to `Reusable`)
     
     - parameter cellType: the `UICollectionViewCell` (`Reusable`-conforming) subclass to register
     
     - eg: `register(_:,forCellWithReuseIdentifier:)`
     */
    func register<T: UICollectionViewCell>(cellType: T.Type) where T: Reusable {
        
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Returns a reusable `UICollectionViewCell` object for the class inferred by the return-type
     
     - parameter indexPath: The index path specifying the location of the cell.
     - parameter cellType: The cell class to dequeue
     
     - returns: A `Reusable`, `UICollectionViewCell` instance
     
     - note: The `cellType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - eg: `dequeueReusableCell(withReuseIdentifier:,for:)`
     */
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T where T: Reusable {
        
        let baseCell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = baseCell as? T else {
            
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
    
    // MARK: - UICollectionReusableView
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Reusable & NibLoadable {
        
        self.register(supplementaryViewType.nib,
                      forSupplementaryViewOfKind: elementKind,
                      withReuseIdentifier: supplementaryViewType.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Reusable {
        
        self.register(supplementaryViewType.self,
                      forSupplementaryViewOfKind: elementKind,
                      withReuseIdentifier: supplementaryViewType.reuseIdentifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String,
                                                                       for indexPath: IndexPath,
                                                                       viewType: T.Type = T.self) -> T where T: Reusable {
        
        let view = self.dequeueReusableSupplementaryView(ofKind: elementKind,
                                                         withReuseIdentifier: viewType.reuseIdentifier,
                                                         for: indexPath)
        guard let typeView = view as? T else {
            
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier) "
                    + "matching type \(viewType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the supplementary view beforehand"
            )
        }
        return typeView
    }
}

