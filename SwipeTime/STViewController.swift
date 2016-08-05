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
    
    // MARK: - Timer

    var duration = 3000
    var timeRemaining: Int?
    
    var timer = NSTimer()
    var unlocked = true
    
    func clearTimer() {
        timer.invalidate()
        timeRemaining = duration
        timeDisplay.text = timeFormatter.formatTime(timeRemaining!)
        unlocked = true
        tapView.enabled = true
    }
    
    func startTimer() {
        guard unlocked else {
            return
        }
        unlocked = false
        tapView.enabled = false
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: #selector(STViewController.tick), userInfo: nil, repeats: true)
        
        soundController.playFirstSound()
    }

    func tick() {
        if timeRemaining > 0 {
            timeRemaining! -= 1
            
            // Here I need to update the time display
            
            timeDisplay.text = timeFormatter.formatTime(timeRemaining!)
            
            if timeRemaining == 0 {
                clearTimer()
                soundController.playSecondSound()
            }
        }
    }
    
    // MARK: - Labels

    
    @IBOutlet var timeDisplay: UILabel!
    
    

    
    // MARK: - Actions
    
    @IBAction func cancelTimer(sender: AnyObject) {
        clearTimer()
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
    
    @IBOutlet var tapView: UITapGestureRecognizer!
    
    // MARK: - Load and Memory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        timeDisplay.font = UIFont.monospacedDigitSystemFontOfSize(64, weight: UIFontWeightRegular)
        clearTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
