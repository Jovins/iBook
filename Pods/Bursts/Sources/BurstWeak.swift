//
//  BurstWeak.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

struct Weak<T: AnyObject> {
    
    init(value: T?) {
        self.value = value
    }
    weak var value: T?
}
