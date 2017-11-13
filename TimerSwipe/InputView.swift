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
    static private let secondsLabelFull = NSLocalizedString("secondsLabelFull", value: " seconds", comment: "A space followed by the word seconds, so it can be concatenated with an integer to form a phrase like '20 seconds'"),
    secondsLabelTruncated = NSLocalizedString("secondsLabelTruncated", value: " sec", comment: "A space followed by an abbreviated word seconds, so it can be concatenated with an integer to form a phrase like '20 sec'")
    private let verticalInset: CGFloat = 0.0, medialInset: CGFloat = 32.0, lateralInset: CGFloat = 16.0
    private lazy var margin = layoutMarginsGuide

    private let innerWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    private let wrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let borderWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.fineLineColor
        view.clipsToBounds = true
        return view
    }()

    private let secondsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = K.largeFont
        label.text = InputView.secondsLabelFull
        return label
    }()
    
    // MARK: Public properties
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Cancel X").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = K.tintColor
        button.contentEdgeInsets = UIEdgeInsetsMake(verticalInset, lateralInset, verticalInset, medialInset)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.accessibilityLabel = NSLocalizedString("cancelAddButton", value: "Cancel new timer", comment: "Cancel the user-initiated action of adding a new timer")
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Save Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = K.tintColor
        button.contentEdgeInsets = UIEdgeInsetsMake(verticalInset, medialInset, verticalInset, lateralInset)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.accessibilityLabel = NSLocalizedString("titleOfAddButton", value: "Create new timer", comment: "")
        // Can’t add a timer until it has a valid time
        button.isEnabled = false
        return button
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = UITextBorderStyle.none
        textField.font = K.largeFont
        textField.placeholder = "0"
        textField.adjustsFontForContentSizeCategory = true
        textField.textAlignment = .right
        textField.returnKeyType = .done
        textField.keyboardType = .numberPad

        // iOS 10 won’t dynamically resize the text field, so give it a sufficient width based on aspect ratio
        if #available(iOS 11, *) {}
        else {
            let fallbackTextFieldAspectRatio: CGFloat = 2.5
            textField.widthAnchor.constraint(equalTo: textField.heightAnchor, multiplier: fallbackTextFieldAspectRatio).isActive = true
        }
        
        textField.accessibilityLabel = NSLocalizedString("descriptionOfTextField", value: "Timer duration in seconds", comment: "")
        return textField
    }()

    private lazy var show: NSLayoutConstraint = wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor)
    private lazy var hide: NSLayoutConstraint = {
        let constraint = borderWrapper.topAnchor.constraint(equalTo: borderWrapper.bottomAnchor)
        constraint.isActive = true
        return constraint
    }()
    
    /// Report whether the constraints are set to make the view visible and toggle visibility
    var isVisible: Bool {
        get {
            return show.isActive
        }
        set {
            // Always deactivate constraints before activating conflicting ones (or else this could be a lot less verbose)
            switch newValue {
            case true:
                // Reduce the size of the seconds label if it is larger than half the width of the input view
                if secondsLabel.bounds.width > (self.bounds.width)/2.0 {
                    secondsLabel.text = InputView.secondsLabelTruncated
                }
                hide.isActive = false
                show.isActive = true
            case false:
                show.isActive = false
                hide.isActive = true
                // Reset the seconds label to its normal size
                secondsLabel.text = InputView.secondsLabelFull
            }
        }
    }
    
    // MARK: Sizing

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: size.height)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: bounds.size.width, height: borderWrapper.bounds.size.height)
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        let verticalGap: CGFloat = 10.0, horizontalGap: CGFloat = 18.0
        let borderHeight: CGFloat = 0.5
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Assemble the subviews
        addSubview(borderWrapper)
        borderWrapper.addSubview(wrapper)
        wrapper.addSubview(cancelButton)
        wrapper.addSubview(innerWrapper)
        wrapper.addSubview(addButton)
        innerWrapper.addSubview(textField)
        innerWrapper.addSubview(secondsLabel)
        
        // Set constraints for the subviews
        
        borderWrapper.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        borderWrapper.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        borderWrapper.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        borderWrapper.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        wrapper.topAnchor.constraint(equalTo: borderWrapper.topAnchor, constant: borderHeight).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: borderWrapper.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: borderWrapper.trailingAnchor).isActive = true
        
        cancelButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: -horizontalGap).isActive = true
        cancelButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true

        innerWrapper.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        innerWrapper.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor).isActive = true
        
        textField.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: verticalGap).isActive = true
        textField.leadingAnchor.constraint(equalTo: innerWrapper.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: secondsLabel.leadingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -verticalGap).isActive = true
        
        secondsLabel.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor).isActive = true
        secondsLabel.trailingAnchor.constraint(equalTo: innerWrapper.trailingAnchor).isActive = true
        
        addButton.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: horizontalGap).isActive = true
        
        // Set the order of elements for accessibility to prevent the parent view from stealing accessibility focus
        accessibilityElements = [cancelButton, textField, addButton]
    }
}
