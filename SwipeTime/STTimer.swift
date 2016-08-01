//
//  STTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/1/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTimer: NSObject {
    
    let timeFormatter = STTimeFormatter()
    let soundController = STSoundController()
    
    var initialCounterValue = 3000
    var currentCounterValue: Int? //Gets a value in readyTimer()
    
    var timer = NSTimer()
    var timerUnlocked = true
    
    func readyTimer() {
        timer.invalidate()
        currentCounterValue = initialCounterValue
        
        // Here I need to insert something to set the text of the time display to the current time.
        
        timerUnlocked = true
        
        // Here I need to enable tapView
    }
    
    func startTimer() {
        guard timerUnlocked else {
            return
        }
        timerUnlocked = false
        
        // Here I need to disable tapView.
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: #selector(STViewController.incrementCounter), userInfo: nil, repeats: true)
        
        soundController.playFirstSound()
    }
    
    func stopTimer() {
        readyTimer()
    }

    func incrementCounter() {
        currentCounterValue! -= 1

        // Here I need to update the time display to the current time
        
        if currentCounterValue <= 0 {
            soundController.playSecondSound()
            stopTimer()
        }
    }
}
