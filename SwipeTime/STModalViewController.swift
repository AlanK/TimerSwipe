//
//  STModalViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/3/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STModalViewController: UIViewController {

    @IBOutlet var timeField: UITextField!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var counter: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeField.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
