//
//  STModalViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/3/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STModalViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var timeField: UITextField!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Make sure to get rid of the keyboard before dismissing the view controller
        timeField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    var userSelectedTime: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeField.delegate = self
        timeField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // This is taken from the Internet. The first bit prevents a crash-on-undo that happens when iOS tries to undo to a change that was blocked by shouldChangeCharactersInRange = false. The second bit only allows characters to be added to the text field if the current number of characters plus the number to be added (minus the range of characters being replaced) is <= 0.
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timeField.resignFirstResponder()
        
        if let userEnteredTime = timeField.text {
            if let userEnteredTimeInCentiseconds = Int(userEnteredTime + "00") {
                if userEnteredTimeInCentiseconds > 0 {
                    userSelectedTime = userEnteredTimeInCentiseconds
                }
            }
        }
        
    }
    
}
