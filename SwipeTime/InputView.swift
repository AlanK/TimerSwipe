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
    /// Dictionary keys
    enum SavedConstraints {
        case wrapperTop
        case wrapperBottom
        case wrapperLeading
        case wrapperTrailing
        case textFieldTop
        case textFieldBottom
        case textFieldLeading
        case textFieldTrailing
        case buttonHugging
        case buttonCompression
        case buttonBaseline
        case buttonTrailing
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
        
        addSubview(wrapper)
        wrapper.addSubview(textField)
        wrapper.addSubview(addButton)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        
        let margin = layoutMarginsGuide, gap: CGFloat = 10.0
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: gap).isActive = true
        textField.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -gap).isActive = true
        textField.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -gap).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addButton.lastBaselineAnchor.constraint(equalTo: textField.lastBaselineAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor).isActive = true
    }
}

