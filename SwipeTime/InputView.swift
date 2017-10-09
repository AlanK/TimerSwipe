//
//  InputView.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 8/29/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

// Based on the CatChat app from https://developer.apple.com/videos/play/wwdc2017/242/
/// Input accessory view that accepts an integer seconds value
class InputView: UIInputView {
    
    // MARK: Private properties
    
    private let wrapper = UIView(), innerWrapper = UIView(), thinLine = UIView()
    private var constraintsToHideView = Set<NSLayoutConstraint>(), constraintsToShowView = Set<NSLayoutConstraint>()

    private let secondsLabel: UILabel = {
        let label = UILabel()
        label.font = K.font
        label.text = NSLocalizedString("secondsLabel", value: " seconds", comment: "A space followed by the word seconds, so it can be concatenated with an integer to form a phrase like '20 seconds'")
        return label
    }()
    
    // MARK: Public properties
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Cancel X"), for: .normal)
        button.tintColor = K.tintColor
        button.accessibilityLabel = NSLocalizedString("cancelAddButton", value: "Cancel new timer", comment: "Cancel the user-initiated action of adding a new timer")
        return button
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Save Arrow"), for: .normal)
        button.tintColor = K.tintColor
        button.accessibilityLabel = NSLocalizedString("titleOfAddButton", value: "Create new timer", comment: "")
        // Can’t add a timer until it has a valid time
        button.isEnabled = false
        return button
    }()
    
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
    
    /// Report whether the constraints are set to make the view visible and toggle visibility
    var isVisible: Bool {
        get {
            guard let isVisible = constraintsToShowView.first?.isActive else {return false}
            return isVisible
        }
        set {
            defer {layoutIfNeeded()}
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
        }
    }
    
    // MARK: Sizing

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: size.height)
    }
    
    override var intrinsicContentSize: CGSize {
        return bounds.size
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        let verticalGap: CGFloat = 10.0, horizontalGap: CGFloat = 18.0
        let thinLineHeight: CGFloat = 0.5
        let verticalInset: CGFloat = 0.0, medialInset: CGFloat = 32.0, lateralInset: CGFloat = 16.0
        let margin = layoutMarginsGuide
        
        // Assemble the subviews
        addSubview(wrapper)
        addSubview(thinLine)
        addSubview(cancelButton)
        wrapper.addSubview(innerWrapper)
        wrapper.addSubview(addButton)
        innerWrapper.addSubview(textField)
        innerWrapper.addSubview(secondsLabel)
        
        // Add colors
        backgroundColor = UIColor.white
        thinLine.backgroundColor = K.thinLineColor
        
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
        
        // Add some padding to the buttons to make them bigger tap targets
        cancelButton.contentEdgeInsets = UIEdgeInsetsMake(verticalInset, lateralInset, verticalInset, medialInset)
        addButton.contentEdgeInsets = UIEdgeInsetsMake(verticalInset, medialInset, verticalInset, lateralInset)
        
        // Make sure the text isn’t any taller than it needs to be
        innerWrapper.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Set constraints for the subviews

        thinLine.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        thinLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        thinLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        thinLine.bottomAnchor.constraint(equalTo: thinLine.topAnchor, constant: thinLineHeight).isActive = true
        
        wrapper.topAnchor.constraint(equalTo: thinLine.bottomAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        
        cancelButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: -horizontalGap).isActive = true
        cancelButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true

        innerWrapper.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        innerWrapper.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: verticalGap).isActive = true
        textField.leadingAnchor.constraint(equalTo: innerWrapper.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: secondsLabel.leadingAnchor).isActive = true
        
        secondsLabel.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor).isActive = true
        secondsLabel.trailingAnchor.constraint(equalTo: innerWrapper.trailingAnchor).isActive = true
        
        addButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: horizontalGap).isActive = true
        
        // iOS 10 won’t dynamically resize the text field, so give it a sufficient width based on aspect ratio
        if #available(iOS 11, *) {}
        else {
            let fallbackTextFieldAspectRatio: CGFloat = 2.5
            textField.widthAnchor.constraint(equalTo: textField.heightAnchor, multiplier: fallbackTextFieldAspectRatio).isActive = true
        }
        
        // Constraints for showing this view
        constraintsToShowView.insert(wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor))
        constraintsToShowView.insert(textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -verticalGap))
        
        // Constraint for hiding this view (make active because this view should start hidden)
        let constraintToHideView = wrapper.bottomAnchor.constraint(equalTo: wrapper.topAnchor)
        constraintToHideView.isActive = true
        constraintsToHideView.insert(constraintToHideView)
        
        // Set the order of elements for accessibility to prevent the parent view from stealing accessibility focus
        accessibilityElements = [cancelButton, textField, addButton]
    }
}
