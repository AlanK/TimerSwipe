//
//  TextFieldDelegate.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 12/11/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    public enum ViewController {
        case tableController(() -> Void)
    }
    
    private let viewController: ViewController
    
    init(_ viewController: ViewController) {
        self.viewController = viewController
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent crash-on-undo when a text insertion was blocked by this code
        let charCount = textField.text?.count ?? 0
        let willNotCrashOnUndo = range.length + range.location <= charCount
        
        switch viewController {
        case .tableController(_):
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            let maxLength = 3
            
            // Prevent non-number characters from being inserted
            let onlyNumbers = string.rangeOfCharacter(from: invalidCharacters) == nil
            // Prevent too many characters from being inserted
            let withinMaxLength = charCount + string.count - range.length <= maxLength
            
            return willNotCrashOnUndo && onlyNumbers && withinMaxLength
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch viewController {
        case .tableController(let createNewTimer):
            createNewTimer()
            return false
        }
    }
}


