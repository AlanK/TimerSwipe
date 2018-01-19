//
//  Countdown.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

/// Responsible for handling changes in countdown status and providing a display that can be updated
protocol CountdownDelegate: class {
    var countdown: Countdown { get }
    /// Handles changes in countdown status
    func countdownDid(_: CountdownStatus)
    /// Updates the countdown display with a value in seconds
    func updateDisplay(with: TimeInterval)
}

/// The object that runs countdowns
class Countdown {
    private unowned let delegate: CountdownDelegate
    /// Duration in seconds
    private let duration: TimeInterval
    /// Reference to the current NSTimer
    private var timer: Timer?
    /// NSDate on which running timer should stop
    private var expirationDate: Date?
    /// Is the countdown ready for a new timer to start?
    private var unlocked = true
    /// Is the countdown ready to start?
    var ready: Bool {
        get { return unlocked }
    }
    
    init(delegate: CountdownDelegate, duration: TimeInterval) {
        self.delegate = delegate
        self.duration = duration
    }
    
    func start() {
        guard unlocked else { return }
        unlocked = false
        
        let startDate = Date.init()
        let expirationDate = Date.init(timeInterval: duration, since: startDate)
        self.expirationDate = expirationDate
        createTimer(expire: expirationDate)
        
        delegate.countdownDid(.start(expirationDate))
    }
    
    func cancel() {
        clear()
        delegate.countdownDid(.cancel)
    }
    
    func sleep() {
        timer?.invalidate()
        timer = nil
    }
    
    func wake() {
        guard let expirationDate = expirationDate, Date.init() < expirationDate else {
            delegate.countdownDid(.expire)
            clear()
            return
        }
        createTimer(expire: expirationDate)
    }
    
    private func clear() {
        timer?.invalidate()
        timer = nil
        expirationDate = nil
        
        unlocked = true
        delegate.updateDisplay(with: duration)
    }
    
    private func createTimer(expire expirationDate: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: K.hundredthOfASecond, repeats: true) { timer in
            let currentTime = Date.init()
            guard currentTime < expirationDate else {
                // If the current time >= the end time, end the timer
                self.clear()
                self.delegate.countdownDid(.end)
                return
            }
            
            // Update the countdown display
            self.delegate.updateDisplay(with: expirationDate.timeIntervalSince(currentTime))
        }
    }
}