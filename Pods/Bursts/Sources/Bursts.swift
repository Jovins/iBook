//
//  Bursts.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

public final class Bursts {
    
    // MARK: - Property
    static let shared = Bursts()
    let delayBetweenBursts: TimeInterval
    let dispatchQueue = DispatchQueue(label: "com.jovins.burst")
    
    weak var autohideToken: BurstPresenter?
    var queue: [BurstPresenter] = []
    var current: BurstPresenter? {
        didSet {
            guard oldValue != nil else { return }
            let delayTime = DispatchTime.now() + delayBetweenBursts
            dispatchQueue.asyncAfter(deadline: delayTime) { [weak self] in
                self?.dequeueNext()
            }
        }
    }
    
    // MARK: - Bursts static Method
    public static func show(_ burst: Burst) {
        shared.show(burst)
    }
    
    public static func hide() {
        shared.hideCurrent()
    }
    
    public static func hideAll() {
        shared.hideAll()
    }
    
    // MARK: - Instance
    public init(delayBetweenBursts: TimeInterval = 0.5) {
        self.delayBetweenBursts = delayBetweenBursts
    }
    
    public func show(_ burst: Burst) {
        
        DispatchQueue.main.async {
            let presenter = BurstPresenter(burst: burst, delegate: self)
            self.enqueue(presenter: presenter)
        }
    }
    
    public func hideCurrent() {
        
        guard let current = current, !current.isHiding else { return }
        DispatchQueue.main.async {
            current.hide(animated: true) { [weak self] completed in
                guard completed, let self = self else { return }
                self.dispatchQueue.sync {
                    guard self.current === current else { return }
                    self.current = nil
                }
            }
        }
    }
    
    public func hideAll() {
        
        dispatchQueue.sync {
            queue.removeAll()
            hideCurrent()
        }
    }
    
    func enqueue(presenter: BurstPresenter) {
        
        queue.append(presenter)
        dequeueNext()
    }
    
    func hide(presenter: BurstPresenter) {
        
        if presenter == current {
            hideCurrent()
        } else {
            queue = queue.filter { $0 != presenter }
        }
    }
    
    func dequeueNext() {
        
        guard current == nil, !queue.isEmpty else { return }
        current = queue.removeFirst()
        autohideToken = current

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let current = self.current else { return }
            current.show { completed in
                guard completed else {
                    self.dispatchQueue.sync {
                        self.hide(presenter: current)
                    }
                    return
                }
                if current === self.autohideToken {
                    self.queueAutoHide()
                }
            }
        }
    }
    
    func queueAutoHide() {
        
        guard let current = current else { return }
        autohideToken = current
        let delayTime = DispatchTime.now() + current.burst.duration.value
        dispatchQueue.asyncAfter(deadline: delayTime) { [weak self] in
            if self?.autohideToken !== current { return }
            self?.hide(presenter: current)
        }
    }
}

// MARK: - BurstAnimatorDelegate
extension Bursts: BurstAnimatorDelegate {

    func hide(animator: BurstAnimator) {

        dispatchQueue.sync { [weak self] in
            guard let presenter = self?.presenter(forAnimator: animator) else { return }
            self?.hide(presenter: presenter)
        }
    }

    func panStarted(animator: BurstAnimator) {

        autohideToken = nil
    }

    func panEnded(animator: BurstAnimator) {

        queueAutoHide()
    }

    private func presenter(forAnimator animator: BurstAnimator) -> BurstPresenter? {

        if let current = current, animator === current.animator {
            return current
        }
        return queue.first { $0.animator === animator }
    }
}
