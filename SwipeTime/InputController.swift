////
////  InputController.swift
////  SwipeTime
////
////  Created by Alan Kantz on 7/3/16.
////  Copyright © 2016 Alan Kantz. All rights reserved.
////
//
//import UIKit
//
///// The modal view for creating new timers
//class InputController: UIViewController {
//    /// Time value accessible to other objects
//    var userSelectedTime: TimeInterval?
//    /// Text field in which the user types
//    @IBOutlet var timeField: UITextField!
//    /// Right nav bar button for submitting selected time
//    @IBOutlet var doneButton: UIBarButtonItem!
//    /// Left nav bar button for cancelling time selection
//    @IBAction func cancel(_ sender: UIBarButtonItem) {
//        escape()
//    }
//    
//    // MARK: View controller
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Bring up the keyboard and prepare to accept text
//        timeField.delegate = self
//        timeField.becomeFirstResponder()
//        timeField.accessibilityLabel = NSLocalizedString("descriptionOfTextField", value: "Duration of timer in seconds", comment: "")
//    }
//    
//    // MARK: Navigation
//    
//    override func accessibilityPerformEscape() -> Bool {
//        escape()
//        return true
//    }
//    
//    /// Dismisses this view controller safely
//    private func escape() {
//        // Make sure to get rid of the keyboard before dismissing the view controller
//        timeField.resignFirstResponder()
//        dismiss(animated: true, completion: nil)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Make sure to get rid of the keyboard before dismissing the view controller
//        timeField.resignFirstResponder()
//        // Create a valid userSelectedTime or exit early
//        guard let text = timeField.text, let userTimeInSeconds = Int(text) else {return}
//        userSelectedTime = TimeInterval(userTimeInSeconds)
//    }
//}
//
//
