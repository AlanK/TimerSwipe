//
//  InputView.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 8/29/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit
/// Input accessory view that accepts an integer seconds value
class InputView: UIInputView {
    // Based on the CatChat app from https://developer.apple.com/videos/play/wwdc2017/242/
    /// View containing text view and send button
    private let wrapper = UIView()
    /// Thin line to differentiate wrapper from any table cells that may be behind it
    private let thinLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.9, alpha: 1.0)
        return view
    }()
    /// Text input view
    let textField: UITextField = {
        let view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.font = K.font
        view.adjustsFontForContentSizeCategory = true
        view.textAlignment = .right
        view.keyboardType = .numberPad
        view.accessibilityLabel = NSLocalizedString("descriptionOfTextField", value: "Duration of timer in seconds", comment: "")
        return view
    }()
    /// Send button
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = K.tintColor
        button.setTitle(NSLocalizedString("titleOfAddButton", value: "Save", comment: "Save a timer with the current value"), for: .normal)
        button.titleLabel?.font = K.font
        return button
    }()
    /// Activating these constraints hides this view
    private var constraintsToHideView = Set<NSLayoutConstraint>()
    /// Activating these constraints shows this view
    private var constraintsToShowView = Set<NSLayoutConstraint>()
    /// Report whether the constraints are set to make the view visible and toggle visibility
    var isVisible: Bool {
        get {
            guard let isVisible = constraintsToShowView.first?.isActive else {return false}
            return isVisible
        }
        set {
            // Always deactivate constraints before activating conflicting ones (or else this could be a lot less verbose)
            switch newValue {
            case true:
                for constraint in constraintsToHideView {
                    constraint.isActive = false
                }
                for constraint in constraintsToShowView {
                    constraint.isActive = true
                }
            case false:
                for constraint in constraintsToShowView {
                    constraint.isActive = false
                }
                for constraint in constraintsToHideView {
                    constraint.isActive = true
                }
            }
            // Don't forget to do layout at the end
            layoutIfNeeded()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: size.height)
    }
    
    override var intrinsicContentSize: CGSize {
        return bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        // Useful shorthand
        let margin = layoutMarginsGuide, gap: CGFloat = 10.0
        // Make it look nice
        backgroundColor = UIColor.white

        // Assemble the subviews
        addSubview(wrapper)
        addSubview(thinLine)
        wrapper.addSubview(textField)
        wrapper.addSubview(addButton)
        // No, do not translate autoresizing mask into constraints for anything…
        translatesAutoresizingMaskIntoConstraints = false
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        thinLine.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        // Use these priorities for the button
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        // Set constraints for the subviews
        
        thinLine.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        thinLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        thinLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        thinLine.bottomAnchor.constraint(equalTo: thinLine.topAnchor, constant: 1.0).isActive = true
        
        wrapper.topAnchor.constraint(equalTo: thinLine.bottomAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: thinLine.bottomAnchor, constant: gap).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 2*gap).isActive = true
        textField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -gap).isActive = true
        
        addButton.lastBaselineAnchor.constraint(equalTo: textField.lastBaselineAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -2*gap).isActive = true
        
        // Constraints for showing this view
        constraintsToShowView.insert(wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor))
        constraintsToShowView.insert(textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -gap))
        
        // Constraint for hiding this view
        constraintsToHideView.insert(wrapper.bottomAnchor.constraint(equalTo: wrapper.topAnchor))
        
        // Start with the view hidden
        for constraint in constraintsToHideView {
            constraint.isActive = true
        }
    }
}

