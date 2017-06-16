//
//  STModalViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/3/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// The modal view for creating new timers
class STModalViewController: UIViewController, UITextFieldDelegate {
    /// Time value accessible to other objects
    var userSelectedTime: Int?
    /// Text field in which the user types
    @IBOutlet var timeField: UITextField!
    /// Right nav bar button for submitting selected time
    @IBOutlet var doneButton: UIBarButtonItem!
    /// Left nav bar button for cancelling time selection
    @IBAction func cancel(_ sender: UIBarButtonItem) {escape()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bring up the keyboard and prepare to accept text
        timeField.delegate = self
        timeField.becomeFirstResponder()
        timeField.accessibilityLabel = NSLocalizedString("descriptionOfTextField", value: "Duration of timer in seconds", comment: "")
    }
    
    // Protect against text-related crashes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent crash-on-undo when iOS tries to undo a change that was blocked by shouldChangeCharactersInRange = false
        let currentCharacterCount = textField.text?.characters.count ?? 0
        // Prevent more than three characters from being put in the text field
        guard (range.length + range.location <= currentCharacterCount) else {return false}
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
    
    // MARK: - Navigation
    
    override func accessibilityPerformEscape() -> Bool {
        escape()
        return true
    }
    
    private func escape() {
        // Make sure to get rid of the keyboard before dismissing the view controller
        timeField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Make sure to get rid of the keyboard before dismissing the view controller
        timeField.resignFirstResponder()
        // Create a valid userSelectedTime or exit early
        guard let text = timeField.text, let userTime = Int(text) else {return}
        let userTimeInCentiseconds = userTime * K.centisecondsPerSecond
        guard userTimeInCentiseconds > 0 else {return}
        userSelectedTime = userTimeInCentiseconds
    }
}
