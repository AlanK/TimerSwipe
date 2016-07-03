//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STViewController: UIViewController {
    
    
    var timer = NSTimer()
    let defaultCounter = 3000
    var counterValue = 3000
    var savedCounter = 3000
    var timerUnlocked = true
    
    func formatTime(time: Int) -> (String) {
        
        let timeBlocks = [time / 6000, (time / 100) % 60, time % 100]
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
        
        var timeAsString = ["", "", ""]
        
        var i = 0
        for block in timeBlocks {
            timeAsString[i] = numberFormatter.stringFromNumber(block)!
            i += 1
        }
        
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
        
    }
    
    func startTimer() {
        guard timerUnlocked else {
            return
        }
        timerUnlocked = false
        tapView.enabled = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: #selector(STViewController.incrementCounter), userInfo: nil, repeats: true)
    }
    
    func incrementCounter() {
        counterValue -= 1
        timeDisplay.text = formatTime(counterValue)
        if counterValue <= 0 {
            stopTimer()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        counterValue = savedCounter
        timeDisplay.text = formatTime(counterValue)
        timerUnlocked = true
        tapView.enabled = true
    }
    
    
    @IBOutlet var timeDisplay: UILabel!
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        stopTimer()
        
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
        if let sourceViewController = sender.sourceViewController as? STModalViewController, newCounter = sourceViewController.counter {
            savedCounter = newCounter
        }
        stopTimer()
    }
    
}
