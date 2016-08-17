//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STViewController: UIViewController {
    
    let timeFormatter = STTimeFormatter()
    let soundController = STSoundController()
    var savedTimerList = STTimerList.sharedInstance
    
    /*
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    */
 

    
    // MARK: - Timer

    var duration = 3000
    var timeRemaining: Int?
    var timer = NSTimer()
    var unlocked = true
    
    func clearTimer() {
        unlocked = true
        timer.invalidate()
        timeRemaining = duration
        timeDisplay.text = timeFormatter.formatTime(timeRemaining!)
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        
        UIView.performWithoutAnimation {
            self.changeButton.setTitle("Change", forState: .Normal)
            self.changeButton.layoutIfNeeded()
        }
    }
    
    func startTimer() {
        guard unlocked else {
            return
        }
        unlocked = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: #selector(STViewController.tick), userInfo: nil, repeats: true)
        soundController.playFirstSound()
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        
        UIView.performWithoutAnimation {
            self.changeButton.setTitle("Cancel", forState: .Normal)
            self.changeButton.layoutIfNeeded()
        }
    }

    func tick() {
        if timeRemaining > 0 {
            timeRemaining! -= 1
            timeDisplay.text = timeFormatter.formatTime(timeRemaining!)
            if timeRemaining == 0 {
                clearTimer()
                soundController.playSecondSound()
            }
        }
    }
    
    // MARK: - Labels & Buttons

    
    @IBOutlet var timeDisplay: UILabel!
    @IBOutlet var changeButton: UIButton!
    
    
    // MARK: - Actions
    
    // Here I use a named segue ("Picker") so I can trigger it programmatically (in this case, conditionally).
    
    @IBAction func changeButton(sender: AnyObject) {
        if unlocked {
            performSegueWithIdentifier("Picker", sender: self)
        }
        else {
            clearTimer()
        }
    }

    
    
    @IBAction func swipeRight(sender: AnyObject) {
        startTimer()
    }
    
    @IBAction func swipeLeft(sender: AnyObject) {
        startTimer()
    }
    
    @IBAction func swipeUp(sender: AnyObject) {
        startTimer()
    }
    
    @IBAction func swipeDown(sender: AnyObject) {
        startTimer()
    }
    
    // MARK: - Load and Memory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeDisplay.font = UIFont.monospacedDigitSystemFontOfSize(64, weight: UIFontWeightRegular)
        clearTimer()
        
        /*
        // Handle starting from the URL scheme.
        duration = appDelegate.providedTime ?? duration
        if appDelegate.startTimer {
            startTimer()
        }
        
        // Clean up after URL scheme.
        appDelegate.providedTime = nil
        appDelegate.startTimer = false
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unwindToSTVC(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? STModalViewController {
            if let userSelectedTime = sourceViewController.userSelectedTime {
                duration = userSelectedTime
            }
        }
        clearTimer()
    }
    



}
