//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

enum ChangeButtonValue: String {
    case cancel = "Cancel"
    case change = "Change"
}

protocol StopwatchDelegate {
    func updateDisplay(with: Int)
    func setButton(to: ChangeButtonValue)
    func timerDidStart()
    func timerDidEnd()
    func timerDidCancel()
}

class Stopwatch {
    let delegate: StopwatchDelegate
    let duration: Int
    
    var endTime: Date?
    var timer: Timer?
    var unlocked = true
    
    init(delegate: StopwatchDelegate, duration: Int? = nil) {
        self.delegate = delegate
        self.duration = duration ?? K.defaultDurationInCentiseconds
    }
    
    func clearTimer() {
        unlocked = true
        timer?.invalidate()
        delegate.updateDisplay(with: duration)
        delegate.setButton(to: .change)
    }
    
    func startTimer() {
        guard unlocked else {return}
        unlocked = false
        let startTime = Date.init()
        endTime = Date.init(timeInterval: (Double(duration)/K.centisecondsPerSecondDouble), since: startTime)
        timer = Timer.scheduledTimer(timeInterval: K.hundredthOfASecond, target:self, selector: #selector(Stopwatch.tick), userInfo: nil, repeats: true)
        delegate.timerDidStart()
        delegate.setButton(to: .cancel)
    }
    
    @objc func tick() {
        let currentTime = Date.init()
        guard currentTime < endTime! else {
            clearTimer()
            delegate.timerDidEnd()
            return
        }
        let timeRemaining = Int(endTime!.timeIntervalSince(currentTime) * K.centisecondsPerSecondDouble)
        delegate.updateDisplay(with: timeRemaining)
    }
    
    func cancel() {
        clearTimer()
        delegate.timerDidCancel()
    }
}
