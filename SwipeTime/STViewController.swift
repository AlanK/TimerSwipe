//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit
import AudioToolbox

class STViewController: UIViewController {
    
    let timeFormatter = STTimeFormatter()
    let soundController = STSoundController()

    // MARK: - Timer

    var initialCounterValue = 3000
    var currentCounterValue: Int? //Gets a value in readyTimer()
    
    var timer = NSTimer()
    var timerUnlocked = true
    
    func readyTimer() {
        timer.invalidate()
        currentCounterValue = initialCounterValue
        timeDisplay.text = timeFormatter.formatTime(currentCounterValue!)
        timerUnlocked = true
        tapView.enabled = true
    }
    
    func startTimer() {
        guard timerUnlocked else {
            return
        }
        timerUnlocked = false
        tapView.enabled = false
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: #selector(STViewController.incrementCounter), userInfo: nil, repeats: true)
        
        soundController.playFirstSound()
    }

    func incrementCounter() {
        currentCounterValue! -= 1
        timeDisplay.text = timeFormatter.formatTime(currentCounterValue!)
        if currentCounterValue <= 0 {
            stopTimer()
        }
    }

    func stopTimer() {
        readyTimer()
        soundController.playSecondSound()
    }
    
    // MARK: - Labels

    
    @IBOutlet var timeDisplay: UILabel!
    
    
    // MARK: - Actions
    
    @IBAction func cancelTimer(sender: AnyObject) {
        stopTimer()
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
        readyTimer()
        
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
            if let newCounter = sourceViewController.counter {
                initialCounterValue = newCounter
            }
        }
        readyTimer()
    }
    
}
