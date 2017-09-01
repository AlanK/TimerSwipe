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
    let wrapper = UIView()
    /// Text input view
    let textField: UITextField = {
        let view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.textAlignment = .right
        view.keyboardType = .numberPad
        return view
    }()
    /// Send button
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = K.tintColor
        button.setTitle("Save", for: .normal)
        return button
    }()
    /// Activating this constraint hides this view
    private var constraintToHideView = Set<NSLayoutConstraint>()
    /// Activating this constraint shows this view
    private var constraintToShowView = Set<NSLayoutConstraint>()
    
    var isVisible: Bool {
        get {
            guard let isVisible = constraintToShowView.first?.isActive else {return false}
            return isVisible
        }
        set {
            // Always deactivate constraints before activating conflicting ones (or else this could be a lot less verbose)
            switch newValue {
            case true:
                for constraint in constraintToHideView {
                    constraint.isActive = false
                }
                for constraint in constraintToShowView {
                    constraint.isActive = true
                }
            case false:
                for constraint in constraintToShowView {
                    constraint.isActive = false
                }
                for constraint in constraintToHideView {
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
        wrapper.addSubview(textField)
        wrapper.addSubview(addButton)
        // No, do not translate autoresizing mask into constraints for anything…
        translatesAutoresizingMaskIntoConstraints = false
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        // Use these priorities for the button
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        // Set constraints for the subviews
        
        wrapper.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: gap).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -gap).isActive = true
        
        addButton.lastBaselineAnchor.constraint(equalTo: textField.lastBaselineAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor).isActive = true
        
        // Constraints for showing this view
        constraintToShowView.insert(wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor))
        constraintToShowView.insert(textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -gap))
        
        // Constraint for hiding this view
        constraintToHideView.insert(wrapper.bottomAnchor.constraint(equalTo: wrapper.topAnchor))
        
        // Start with the view hidden
        for constraint in constraintToHideView {
            constraint.isActive = true
        }
    }
}

