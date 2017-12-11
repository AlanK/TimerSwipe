//
//  TextFieldDelegate.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 12/11/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    private let viewController: UIViewController
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charCount = textField.text?.count ?? 0
        
        // Prevent crash-on-undo when a text insertion was blocked by this code
        let willNotCrashOnUndo = range.length + range.location <= charCount
        
        if let _ = viewController as? TableController {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            let maxLength = 3
            
            // Prevent non-number characters from being inserted
            let onlyNumbers = string.rangeOfCharacter(from: invalidCharacters) == nil
            // Prevent too many characters from being inserted
            let withinMaxLength = charCount + string.count - range.length <= maxLength
            
            return willNotCrashOnUndo && onlyNumbers && withinMaxLength
        } else {
            return willNotCrashOnUndo
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let viewController = viewController as? TableController {
            viewController.createNewTimer()
            return false
        } else {
            return true
        }
    }
}


