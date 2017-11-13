//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

/// Responsible for providing a locking system (to prevent concurrency), timer completion handlers, and a display updater
protocol StopwatchDelegate {
    // NOTE: The indirection in timerReady/lock/unlock allows Stopwatch to be a struct. Don't collapse it all into an unlocked {get set} unless you're prepared to make Stopwatch a class.
    /// Reports whether a timer is ready to run
    var timerReady: Bool {get}
    /// Locks to prevent starting a new timer
    func lock()
    /// Unlocks to allow starting a new timer
    func unlock()
    /// Handles changes in timer status
    func timerDid(_: TimerStatus)
    /// Updates the stopwatch display with a value in seconds
    func updateDisplay(with: TimeInterval)
}

/// Enables other parts of the app to check for and kill running timers
protocol StopwatchIntermediary {
    /// Reports whether a timer is ready to run
    var timerReady: Bool {get}
    /// Causes any active timer to die with an audible warning to the user
    func killTimer()
}

/// The object that runs timers
struct Stopwatch {
    private let delegate: StopwatchDelegate
    /// Duration in seconds
    private let duration: TimeInterval
    
    init(delegate: StopwatchDelegate, duration: TimeInterval) {
        self.delegate = delegate
        self.duration = duration
    }
    
    func startTimer() {
        guard delegate.timerReady else {return}
        delegate.lock()
        let startTime = Date.init()
        let endTime = Date.init(timeInterval: duration, since: startTime)
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
        guard delegate.timerReady == false else {
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
        delegate.updateDisplay(with: endTime.timeIntervalSince(currentTime))
    }
}
