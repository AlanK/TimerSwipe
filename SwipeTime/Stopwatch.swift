//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

enum ChangeButtonValues {
    case Cancel
    case Change
    
    var text: String {
        switch self {
        case .Cancel: return "Cancel"
        case .Change: return "Change"
        }
    }
}

protocol StopwatchDelegate {
    func updateDisplay(with: Int)
    func setButton(to: ChangeButtonValues)
    func timerDidStart()
    func timerDidEnd()
}

class Stopwatch {
    let delegate: StopwatchDelegate
    
    var duration = 3000
    var providedDuration: Int?
    var timeRemaining: Int?
    var startTime: Date?
    var endTime: Date?
    var timer = Timer()
    var unlocked = true
    
    init(delegate: StopwatchDelegate, duration: Int? = nil) {
        self.delegate = delegate
        self.duration = duration ?? self.duration
    }
    
    func clearTimer() {
        unlocked = true
        timer.invalidate()
        timeRemaining = duration
        
        guard let timeRemaining = timeRemaining else {return}
        delegate.updateDisplay(with: timeRemaining)
        delegate.setButton(to: .Change)
    }
    
    func startTimer() {
        guard unlocked else {return}
        unlocked = false
        startTime = Date.init()
        endTime = Date.init(timeInterval: (Double(duration)/100.0), since: startTime!)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(Stopwatch.tick), userInfo: nil, repeats: true)
        
        delegate.timerDidStart()
        delegate.setButton(to: .Cancel)
    }
    
    @objc func tick() {
        let currentTime = Date.init()
        guard currentTime < endTime! else {
            clearTimer()
            
            delegate.timerDidEnd()
            return
        }
        let timeRemaining = Int(endTime!.timeIntervalSince(currentTime) * 100)
        
        delegate.updateDisplay(with: timeRemaining)
    }
}
