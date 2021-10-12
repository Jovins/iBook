//
//  GeneratorManager.swift
//  fideo
//
//  Created by Jovins on 2020/6/30.
//  Copyright © 2020 hanron. All rights reserved.
//

import UIKit

class GeneratorManager {

    enum FeedbackType: Int {
        
        case light  = 0
        case medium
        case heavy
        case soft
        case rigid
        case error
        case success
        case warning
        case selected
    }
    
    static let shared = GeneratorManager()

    /// 震动效果
    func impactFeedBack(_ style: FeedbackType) {
        
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            break
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            break
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
            break
        case .soft:
            if #available(iOS 13.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.prepare()
                generator.impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            }
            break
        case .rigid:
            if #available(iOS 13.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.prepare()
                generator.impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }
            break
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            break
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
            break
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
            break
        case .selected:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            break
        }
    }
}

