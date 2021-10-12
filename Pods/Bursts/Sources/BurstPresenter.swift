//
//  BurstPresenter.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

final class BurstPresenter: NSObject {
    
    // MARK: - Property
    let burst: Burst
    let animator: BurstAnimator
    var isHiding = false
    
    let maskingView = BurstThroughView()
    let view: UIView
    let viewController: Weak<WindowViewController>
    let context: BurstAnimationContext
    
    init(burst: Burst, delegate: BurstAnimatorDelegate) {
        
        self.burst = burst
        self.view = BurstView(burst: burst)
        self.viewController = .init(value: WindowViewController())
        self.animator = BurstAnimator(position: self.burst.position, delegate: delegate)
        self.context = BurstAnimationContext(view: view, container: maskingView)
    }

    // MARK: - Method
    func show(completion: @escaping AnimationCompletion) {
        
        install()
        self.animator.show(context: context) { [weak self] completed in
            if let burst = self?.burst {
                self?.announcementAccessibilityMessage(for: burst)
            }
            completion(completed)
        }
    }

    func hide(animated: Bool, completion: @escaping AnimationCompletion) {
        
        isHiding = true
        let action = { [weak self] in
            self?.viewController.value?.uninstall()
            self?.maskingView.removeFromSuperview()
            completion(true)
        }
        guard animated else {
            action()
            return
        }
        self.animator.hide(context: context) { _ in
            action()
        }
    }

    func install() {
        
        guard let container = viewController.value else { return }
        guard let containerView = container.view else { return }

        container.install()
        maskingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(maskingView)

        NSLayoutConstraint.activate([
            maskingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            maskingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            maskingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            maskingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        containerView.layoutIfNeeded()
    }

    func announcementAccessibilityMessage(for burst: Burst) {
        
        UIAccessibility.post(
            notification: UIAccessibility.Notification.announcement,
            argument: burst.accessibility.message
        )
    }
}
