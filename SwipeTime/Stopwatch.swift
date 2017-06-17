//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

/// Controls the value of the Change/Cancel button
enum ChangeButtonValue {
    case cancel
    case change
    
    /// Returns a localized string with text for the Change/Cancel button
    var text: String {
        switch self {
        case .cancel: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        case .change: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        }
    }
}

/// Message announcing changes in timer status
enum TimerStatus {
    case start
    case end
    case cancel
}

/// Responsible for providing a locking system (to prevent concurrency), timer completion handlers, and a display updater
protocol StopwatchDelegate {
    /// Controls whether or not the stopwatch can start a new timer
    var unlocked: Bool {get}
    /// Locks to prevent starting a new timer
    func lock()
    /// Unlocks to allow starting a new timer
    func unlock()
    /// Handles changes in timer status
    func timerDid(_: TimerStatus)
    /// Updates the stopwatch display
    func updateDisplay(with: Int)
}

/// The object that runs timers
struct Stopwatch {
    private let delegate: StopwatchDelegate
    /// Duration in centiseconds
    private let duration: Int
    
    init(delegate: StopwatchDelegate, duration: Int) {
        self.delegate = delegate
        self.duration = duration
    }
    
    func startTimer() {
        guard delegate.unlocked else {return}
        delegate.lock()
        let startTime = Date.init()
        let endTime = Date.init(timeInterval: (Double(duration)/K.centisecondsPerSecondDouble), since: startTime)
        Timer.scheduledTimer(withTimeInterval: K.hundredthOfASecond, repeats: true) {timer in
            self.tick(timer, until: endTime)
        }
        delegate.timerDid(.start)
    }
    
    func clear(timer: Timer? = nil) {
        timer?.invalidate()
        delegate.unlock()
        delegate.updateDisplay(with: duration)
    }
    
    /// Called every time the `NSTimer` fires
    private func tick(_ timer: Timer, until endTime: Date) {
        guard delegate.unlocked == false else {
            // If the flag has been set by the delegate, cancel the timer
            clear(timer: timer)
            delegate.timerDid(.cancel)
            return
        }
        let currentTime = Date.init()
        guard currentTime < endTime else {
            // If the current time >= the end time, end the timer
            clear(timer: timer)
            delegate.timerDid(.end)
            return
        }
        // Update the stopwatch display
        let timeRemaining = Int(endTime.timeIntervalSince(currentTime) * K.centisecondsPerSecondDouble)
        delegate.updateDisplay(with: timeRemaining)
    }
}
