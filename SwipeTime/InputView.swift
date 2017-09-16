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
    private let gap: CGFloat = 10.0
    // Based on the CatChat app from https://developer.apple.com/videos/play/wwdc2017/242/
    /// View containing text view and send button
    private let wrapper: UIView = {
        let view = UIView()
        return view
    }()
    /// Thin line to differentiate wrapper from any table cells that may be behind it
    private let thinLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 2.0/3.0, alpha: 1.0)
        return view
    }()
    /// Cancel button
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = K.tintColor
        button.accessibilityLabel = NSLocalizedString("cancelAddButton", value: "Cancel new timer", comment: "Cancel the user-initiated action of adding a new timer")
        button.setImage(UIImage(named: "Cancel X"), for: .normal)
        // Add some padding to make the buttons bigger tap targets. More padding on the medial side
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 32.0)
        return button
    }()
    /// Inner wrapper containing the text field and seconds label
    let innerWrapper = UIView()
    /// Text input view
    let textField: UITextField = {
        let view = UITextField()
        view.borderStyle = UITextBorderStyle.none
        view.font = K.font
        view.placeholder = "0"
        view.adjustsFontForContentSizeCategory = true
        view.textAlignment = .right
        view.returnKeyType = .done
        view.keyboardType = .numberPad
        view.accessibilityLabel = NSLocalizedString("descriptionOfTextField", value: "Timer duration in seconds", comment: "")
        return view
    }()
    /// "Seconds" label
    let secondsLabel: UILabel = {
        let label = UILabel()
        label.font = K.font
        label.text = NSLocalizedString("secondsLabel", value: " seconds", comment: "A space followed by the word seconds, so it can be concatenated with an integer to form a phrase like '20 seconds'")
        return label
    }()
    /// Send button
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = K.tintColor
        button.accessibilityLabel = NSLocalizedString("titleOfAddButton", value: "Create new timer", comment: "")
        button.setImage(UIImage(named: "Save Arrow"), for: .normal)
        // Add some padding to make the buttons bigger tap targets. More padding on the medial side
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 32.0, 0.0, 16.0)
        button.isEnabled = false
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
        let margin = layoutMarginsGuide
        
        backgroundColor = UIColor.white

        // Assemble the subviews
        addSubview(wrapper)
        addSubview(thinLine)
        addSubview(cancelButton)
        wrapper.addSubview(innerWrapper)
        innerWrapper.addSubview(textField)
        innerWrapper.addSubview(secondsLabel)
        wrapper.addSubview(addButton)
        // No, do not translate autoresizing mask into constraints for anything…
        translatesAutoresizingMaskIntoConstraints = false
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        thinLine.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        innerWrapper.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        secondsLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        // No squash or stretch on the buttons
        cancelButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        // Make sure the text isn’t any taller than it needs to be
        innerWrapper.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Set constraints for the subviews
        
        thinLine.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        thinLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        thinLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        thinLine.bottomAnchor.constraint(equalTo: thinLine.topAnchor, constant: 0.5).isActive = true
        
        wrapper.topAnchor.constraint(equalTo: thinLine.bottomAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        
        cancelButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: -18).isActive = true
        cancelButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true

        innerWrapper.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        innerWrapper.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: gap).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: innerWrapper.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: secondsLabel.leadingAnchor).isActive = true
        
        secondsLabel.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor).isActive = true
        secondsLabel.trailingAnchor.constraint(equalTo: innerWrapper.trailingAnchor).isActive = true
        
        addButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: 18).isActive = true
        
        // iOS 10 won’t dynamically resize the text field, so give it a sufficient width based on aspect ratio
        if #available(iOS 11, *) {}
        else {
            textField.widthAnchor.constraint(equalTo: textField.heightAnchor, multiplier: 2.5).isActive = true
        }
        
        // Constraints for showing this view
        constraintsToShowView.insert(wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor))
        constraintsToShowView.insert(textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -gap))
        
        // Constraint for hiding this view
        constraintsToHideView.insert(wrapper.bottomAnchor.constraint(equalTo: wrapper.topAnchor))
        
        // Start with the view hidden
        for constraint in constraintsToHideView {
            constraint.isActive = true
        }
        
        // Set the order of elements for accessibility to prevent the parent view from stealing accessibility focus
        accessibilityElements = [cancelButton, textField, addButton]
    }
}

