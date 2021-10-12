//
//  Burst.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

public struct Burst: ExpressibleByStringLiteral {
    
    public var title: String
    public var subtitle: String?
    public var icon: UIImage?
    public var action: Action?
    public var position: Position
    public var duration: Duration
    public var setting: BurstSetting
    public var accessibility: Accessibility
    
    public init(
        title: String,
        subtitle: String? = nil,
        icon: UIImage? = nil,
        action: Action? = nil,
        position: Position = .top,
        duration: Duration = .recommend,
        setting: BurstSetting? = nil,
        accessibility: Accessibility? = nil
    ) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let subtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
            self.subtitle = subtitle
        }
        self.icon = icon
        self.action = action
        self.position = position
        self.duration = duration
        self.setting = setting ?? BurstSetting()
        self.accessibility = accessibility
            ?? .init(message: [title, subtitle].compactMap({ $0 }).joined(separator: ", "))
    }
    
    public init(stringLiteral title: String) {
        self.title = title
        self.position = .top
        self.duration = .recommend
        self.setting = BurstSetting()
        self.accessibility = .init(message: title)
    }
}


extension Burst {
    
    public enum Position: Equatable {
        case top
        case bottom
    }
    
    public enum Duration: Equatable, ExpressibleByFloatLiteral {
        
        /// 推荐2s
        case recommend
        case seconds(TimeInterval)
        
        public init(floatLiteral value: TimeInterval) {
            self = .seconds(value)
        }
        
        internal var value: TimeInterval {
            switch self {
            case .recommend:
                return 2.0
            case .seconds(let custom):
                return abs(custom)
            }
        }
    }
    
    public struct Action {
        
        public var icon: UIImage?
        public var handler: () -> Void
        public init(icon: UIImage? = nil, handler: @escaping () -> Void) {
            self.icon = icon
            self.handler = handler
        }
    }
    
    public struct Accessibility: ExpressibleByStringLiteral {
        
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
        
        public init(stringLiteral message: String) {
            self.message = message
        }
    }
}
