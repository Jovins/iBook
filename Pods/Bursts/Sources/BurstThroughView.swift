//
//  BurstThroughView.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

final class BurstThroughView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
