//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

/// Responsible for providing a locking system (to prevent concurrency), timer completion handlers, and a display updater
protocol StopwatchDelegate: NSObjectProtocol {
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

/// The object that runs timers
class Stopwatch {
    private unowned let delegate: StopwatchDelegate
    /// Duration in seconds
    private let duration: TimeInterval
    
    private var timer: Timer?
    
    private var expirationDate: Date?
    
    init(delegate: StopwatchDelegate, duration: TimeInterval) {
        self.delegate = delegate
        self.duration = duration
    }
    
    /// Returns the exact time at which the timer will end
    func start() {
        guard delegate.timerReady else { return }
        delegate.lock()
        
        let startTime = Date.init()
        let endTime = Date.init(timeInterval: duration, since: startTime)
        timer = createTimer(withEndTime: endTime)
        
        expirationDate = endTime
        
        delegate.timerDid(.start(endTime))
    }
    
    func clear() {
        timer?.invalidate()
        expirationDate = nil
        
        delegate.unlock()
        delegate.updateDisplay(with: duration)
    }
    
    func sleep() {
        timer?.invalidate()
    }
    
    func wake() {
        guard let expirationDate = expirationDate, Date.init() < expirationDate else {
            delegate.timerDid(.expire)
            clear()
            return
        }
        timer = createTimer(withEndTime: expirationDate)
    }
    
    private func createTimer(withEndTime endTime: Date) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: K.hundredthOfASecond, repeats: true) { timer in
            guard self.delegate.timerReady == false else {
                // If the flag has been set by the delegate, cancel the timer
                self.clear()
                self.delegate.timerDid(.cancel)
                return
            }
            
            let currentTime = Date.init()
            guard currentTime < endTime else {
                // If the current time >= the end time, end the timer
                self.clear()
                self.delegate.timerDid(.end)
                return
            }
            
            // Update the stopwatch display
            self.delegate.updateDisplay(with: endTime.timeIntervalSince(currentTime))
        }
        
        return timer
    }
}
