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
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        // Make sure to get rid of the keyboard before dismissing the view controller
        timeField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var counter: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeField.delegate = self
        timeField.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // This is taken from the Internet. The first bit prevents a crash-on-undo that happens when iOS tries to undo to a change that was blocked by shouldChangeCharactersInRange = false. The second bit only allows characters to be added to the text field if the current number of characters plus the number to be added (minus the range of characters being replaced) is <= 0.
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        timeField.resignFirstResponder()
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let counterText = timeField.text {
            if let counterNumber = Int(counterText + "00") {
                if counterNumber > 0 {
                    counter = counterNumber
                }
            }
        }
        
    }
    
}
