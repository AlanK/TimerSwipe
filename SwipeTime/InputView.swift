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
    let textView = UITextView()
    /// Send button
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        addSubview(wrapper)
        wrapper.addSubview(textView)
        wrapper.addSubview(sendButton)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        
        let margin = layoutMarginsGuide, gap: CGFloat = 10.0
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        wrapper.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        wrapper.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: gap).isActive = true
        textView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -gap).isActive = true
        textView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: gap).isActive = true
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -gap).isActive = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        sendButton.lastBaselineAnchor.constraint(equalTo: textView.lastBaselineAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor).isActive = true
    }
    
}
