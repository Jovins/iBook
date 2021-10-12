//
//  BurstThroughWindow.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

final class BurstThroughWindow: UIWindow {
    
    private weak var hitBustView: UIView?
    init(hitBustView: UIView) {
        self.hitBustView = hitBustView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        if let view = view, let hitBurstView = self.hitBustView, hitBurstView.isDescendant(of: view) &&  hitBustView != view {
            return nil
        }
        return view
    }
}
