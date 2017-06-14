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
        self.duration = duration ?? constants.defaultDurationInCentiseconds
    }
    
    func clearTimer() {
        unlocked = true
        timer?.invalidate()
        delegate.updateDisplay(with: duration)
        delegate.setButton(to: .Change)
    }
    
    func startTimer() {
        guard unlocked else {return}
        unlocked = false
        let startTime = Date.init()
        endTime = Date.init(timeInterval: (Double(duration)/constants.centisecondsPerSecond), since: startTime)
        timer = Timer.scheduledTimer(timeInterval: constants.hundredthOfASecond, target:self, selector: #selector(Stopwatch.tick), userInfo: nil, repeats: true)
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
        let timeRemaining = Int(endTime!.timeIntervalSince(currentTime) * constants.centisecondsPerSecond)
        delegate.updateDisplay(with: timeRemaining)
    }
    
    func cancel() {
        clearTimer()
        delegate.timerDidCancel()
    }
}
