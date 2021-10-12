//
//  BurstAnimator.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

typealias AnimationCompletion = (_ completed: Bool) -> Void

protocol BurstAnimatorDelegate: AnyObject {
    func hide(animator: BurstAnimator)
    func panStarted(animator: BurstAnimator)
    func panEnded(animator: BurstAnimator)
}

final class BurstAnimator {
    
    // MARK: - Property
    weak var delegate: BurstAnimatorDelegate?
    var context: BurstAnimationContext?
    var state: PanState = PanState()
    
    let position: Burst.Position
    let showDuration: TimeInterval = 0.75
    let hideDuration: TimeInterval = 0.25
    let springDamping: CGFloat = 0.8
    let rubberBanding = true
    let closeSpeedThreshold: CGFloat = 750.0
    let closePercentThreshold: CGFloat = 0.33
    let closeAbsoluteThreshold: CGFloat = 75.0
    let bounceOffset: CGFloat = 5
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handlePan(pan:)))
        return recognizer
    }()
    
    struct PanState: Equatable {
        
        var closing = false
        var closeSpeed: CGFloat = 0.0
        var closePercent: CGFloat = 0.0
        var panTranslationY: CGFloat = 0.0
    }
    
    init(position: Burst.Position, delegate: BurstAnimatorDelegate) {
        self.position = position
        self.delegate = delegate
    }
    
    // MARK: - Method
    func install(context: BurstAnimationContext) {
        
        let view = context.view
        let container = context.container
        self.context = context
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        var constraints = [
            view.centerXAnchor.constraint(equalTo: container.safeArea.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.safeArea.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(lessThanOrEqualTo: container.safeArea.trailingAnchor, constant: -20)
        ]
        switch self.position {
        case .top:
            constraints += [
                view.topAnchor.constraint(equalTo: container.safeArea.topAnchor, constant: bounceOffset)
            ]
        case .bottom:
            constraints += [
                view.bottomAnchor.constraint(equalTo: container.safeArea.bottomAnchor, constant: -bounceOffset)
            ]
        }
        NSLayoutConstraint.activate(constraints)
        container.layoutIfNeeded()
        
        let animationDistance = view.frame.height
        switch self.position {
        case .top:
            view.transform = CGAffineTransform(translationX: 0, y: -animationDistance)
        case .bottom:
            view.transform = CGAffineTransform(translationX: 0, y: animationDistance)
        }
        view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    func show(context: BurstAnimationContext, completion: @escaping AnimationCompletion) {
        
        install(context: context)
        show(completion: completion)
    }
    
    func hide(context: BurstAnimationContext, completion: @escaping AnimationCompletion) {
        
        let position = self.position
        let view = context.view
        UIView.animate(
            withDuration: hideDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn],
            animations: { [weak view] in
                view?.alpha = 0
                let frame = view?.frame ?? .zero
                switch position {
                case .top:
                    view?.transform = CGAffineTransform(translationX: 0, y: -frame.height)
                case .bottom:
                    view?.transform = CGAffineTransform(translationX: 0, y: frame.maxY + frame.height)
                }
            },
            completion: completion
        )
    }
    
    func show(completion: @escaping AnimationCompletion) {
        
        guard let view = self.context?.view else {
            completion(false)
            return
        }
        view.alpha = 0
        let animationDistance = abs(view.transform.ty)
        let springVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, self.state.closeSpeed / animationDistance)
        UIView.animate(
            withDuration: showDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
            animations: { [weak view] in
                guard let view = view else { return }
                view.alpha = 1
                view.transform = .identity
            },
            completion: completion
        )
    }
    
    @objc
    func handlePan(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            guard let view = self.context?.view else { return }
            let velocity = pan.velocity(in: view)
            let translation = pan.translation(in: view)
            self.state = panChanged(current: self.state, view: view, velocity: velocity, translation: translation)
        case .ended, .cancelled:
            if let initialState = panEnded(current: self.state) {
                show { [weak self] _ in
                    
                    guard let `self` = self else { return }
                    self.delegate?.panEnded(animator: self)
                }
                self.state = initialState
            }
        default:
            break
        }
    }
    
    func panChanged(current: PanState, view: UIView, velocity: CGPoint, translation: CGPoint) -> PanState {
        
        var state = current
        var velocity = velocity
        var translation = translation
        let height = view.bounds.height - self.bounceOffset
        if height < 0 {
            return state
        }
        if case .top = position {
            velocity.y *= -1.0
            translation.y *= -1.0
        }
        var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)
        if !state.closing {
            if !self.rubberBanding && translationAmount < 0 {
                return state
            }
            state.closing = true
            self.delegate?.panStarted(animator: self)
        }
        if !rubberBanding && translationAmount < 0 {
            translationAmount = 0
        }
        
        switch position {
        case .top:
            view.transform = CGAffineTransform(translationX: 0, y: -translationAmount)
        case .bottom:
            view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
        }
        
        state.closeSpeed = velocity.y
        state.closePercent = translation.y / height
        state.panTranslationY = translation.y
        return state
    }
    
    func panEnded(current: PanState) -> PanState? {
        
        if current.closeSpeed > closeSpeedThreshold {
            delegate?.hide(animator: self)
            return nil
        }

        if current.closePercent > closePercentThreshold {
            delegate?.hide(animator: self)
            return nil
        }

        if current.panTranslationY > closeAbsoluteThreshold {
            delegate?.hide(animator: self)
            return nil
        }
        return .init()
    }
}
