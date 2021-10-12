//
//  BurstView.swift
//  Burst
//
//  Created by Jovins on 2021/3/18.
//

import UIKit

internal final class BurstView: UIView {
    
    // MARK: - init
    let burst: Burst
    required init(burst: Burst) {
        
        self.burst = burst
        super.init(frame: .zero)
        
        if self.burst.setting.isDefault {
            if #available(iOS 13.0, *) {
                backgroundColor = .secondarySystemBackground
            } else {
                backgroundColor = .white
            }
        } else {
            backgroundColor = self.burst.setting.backgroundColor
        }

        addSubview(stackView)
        let constraints = createLayoutConstraints(for: burst)
        NSLayoutConstraint.activate(constraints)
        configureViews(for: burst)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var frame: CGRect {
        didSet { layer.cornerRadius = frame.cornerRadius }
    }

    override var bounds: CGRect {
        didSet { layer.cornerRadius = frame.cornerRadius }
    }

    // MARK: - Method
    func createLayoutConstraints(for burst: Burst) -> [NSLayoutConstraint] {
        
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            imageView.heightAnchor.constraint(equalToConstant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 25)
        ]

        constraints += [
            button.heightAnchor.constraint(equalToConstant: 35),
            button.widthAnchor.constraint(equalToConstant: 35)
        ]

        var insets = UIEdgeInsets(top: 7.5, left: 12.5, bottom: 7.5, right: 12.5)

        if burst.icon == nil {
            insets.left = 40
        }

        if burst.action?.icon == nil {
            insets.right = 40
        }

        if burst.subtitle == nil {
            insets.top = 15
            insets.bottom = 15
            if burst.action?.icon != nil {
                insets.top = 10
                insets.bottom = 10
                insets.right = 10
            }
        }

        if burst.icon == nil && burst.action?.icon == nil {
            insets.left = 50
            insets.right = 50
        }

        constraints += [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: insets.top),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        ]
        return constraints
    }

    func configureViews(for burst: Burst) {
        
        clipsToBounds = true
        titleLabel.text = burst.title

        subtitleLabel.text = burst.subtitle
        subtitleLabel.isHidden = burst.subtitle == nil

        imageView.image = burst.icon
        imageView.isHidden = burst.icon == nil

        button.setImage(burst.action?.icon, for: .normal)
        button.isHidden = burst.action?.icon == nil

        if let action = burst.action, action.icon == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
            addGestureRecognizer(tap)
        }

        layer.shadowColor = burst.setting.shadowColor.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 25
        layer.shadowOpacity = 0.15
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.masksToBounds = false
    }

    @objc
    func didTapButton() {
        burst.action?.handler()
    }

    // MARK: - Lazy
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        if self.burst.setting.isDefault {
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
        } else {
            label.textColor = self.burst.setting.titleColor
        }
        
        label.font = UIFont.preferredFont(forTextStyle: .subheadline).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        
        if self.burst.setting.isDefault {
            if #available(iOS 13.0, *) {
                label.textColor = UIAccessibility.isDarkerSystemColorsEnabled ? .label : .secondaryLabel
            } else {
                label.textColor = UIAccessibility.isDarkerSystemColorsEnabled ? .black : .darkGray
            }
        } else {
            label.textColor = self.burst.setting.subtitleColor
        }
        
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var imageView: UIImageView = {
        let view = RoundImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.tintColor = .blue
        return view
    }()

    lazy var button: UIButton = {
        let button = RoundButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = .init(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        return button
    }()

    lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = -1
        return view
    }()

    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, labelsStackView, button])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        if burst.icon != nil && burst.action?.icon != nil {
            view.spacing = 20
        } else {
            view.spacing = 15
        }
        return view
    }()
}

final class RoundButton: UIButton {
    override var bounds: CGRect {
        didSet { layer.cornerRadius = frame.cornerRadius }
    }
}

final class RoundImageView: UIImageView {
    override var bounds: CGRect {
        didSet { layer.cornerRadius = frame.cornerRadius }
    }
}

extension UIFont {
    var bold: UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

extension CGRect {
    var cornerRadius: CGFloat {
        return min(width, height) / 2
    }
}

