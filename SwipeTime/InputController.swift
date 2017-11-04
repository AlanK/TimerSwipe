//
//  InputController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 10/25/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

class InputController: UIResponder {
    private let parent: TableController
    
    private let keyboardAccessoryView: InputView = {
        let view = InputView(frame: .zero, inputViewStyle: .default)
        view.cancelButton.addTarget(self, action: #selector(exitKeyboardAccessoryView), for: .touchUpInside)
        view.addButton.addTarget(self, action: #selector(commitNewTimer), for: .touchUpInside)
        return view
    }()
    
    init(parent: TableController) {
        self.parent = parent
        super.init()
        keyboardAccessoryView.textField.delegate = self
        keyboardAccessoryView.textField.addTarget(self, action: #selector(textInTextFieldChanged(_:)), for: UIControlEvents.editingChanged)
    }
    
    func activate() {
        print("Got to the inputController")
        keyboardAccessoryView.addButton.isEnabled = false
        keyboardAccessoryView.isVisible = true
        keyboardAccessoryView.textField.becomeFirstResponder()
    }
}

extension InputController {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIInputView? {
        return keyboardAccessoryView
    }
    
    /// Enable and disable the add button based on whether there is text in the text field
    @objc func textInTextFieldChanged(_ textField: UITextField) {
        let isEnabled: Bool
        if let text = textField.text {
            isEnabled = (text.characters.count > 0)
        } else {
            isEnabled = false
        }
        keyboardAccessoryView.addButton.isEnabled = isEnabled
    }
    
    
    /// Resets and hides the input accessory
    @objc func exitKeyboardAccessoryView() {
        guard keyboardAccessoryView.isVisible else {return}
        // Clear the text field
        keyboardAccessoryView.textField.text?.removeAll()
        // Ditch the keyboard and hide
        keyboardAccessoryView.textField.resignFirstResponder()
        keyboardAccessoryView.isVisible = false
    }
    
    override func accessibilityPerformEscape() -> Bool {
        exitKeyboardAccessoryView()
        return true
    }
    
    @objc func commitNewTimer() {
        defer {
            exitKeyboardAccessoryView()
        }
        // Create a valid userSelectedTime or exit early
        guard let text = keyboardAccessoryView.textField.text, let userTimeInSeconds = Int(text), userTimeInSeconds > 0 else {return}
        let userSelectedTime = TimeInterval(userTimeInSeconds)
        parent.commitTimer(userSelectedTime)
    }
}

// MARK: - Text Field Delegate
extension InputController: UITextFieldDelegate {
    // Protect against text-related problems
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charCount = textField.text?.characters.count ?? 0
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        let maxLength = 3
        
        // Prevent crash-on-undo when a text insertion was blocked by this code
        // Prevent non-number characters from being inserted
        // Prevent too many characters from being inserted
        return (range.length + range.location <= charCount &&
            string.rangeOfCharacter(from: invalidCharacters) == nil &&
            charCount + string.characters.count - range.length <= maxLength)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitNewTimer()
        return false
    }
}


