//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

/// Responsible for handling changes in timer status and providing a display that can be updated
protocol StopwatchDelegate: class {
    var stopwatch: Stopwatch { get }
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
    
    var timerReady = true
    
    init(delegate: StopwatchDelegate, duration: TimeInterval) {
        self.delegate = delegate
        self.duration = duration
    }
    
    func ready() {
        delegate.updateDisplay(with: duration)
    }
    
    func start() {
        guard timerReady else { return }
        timerReady = false
        
        let startTime = Date.init()
        expirationDate = Date.init(timeInterval: duration, since: startTime)
        
        guard let expirationDate = expirationDate else { return }
        createTimer(withEndTime: expirationDate)
        
        delegate.timerDid(.start(expirationDate))
    }
    
    func cancel() {
        clear()
        delegate.timerDid(.cancel)
    }
    
    private func clear() {
        timer?.invalidate()
        timer = nil
        expirationDate = nil
        
        timerReady = true
        delegate.updateDisplay(with: duration)
    }
    
    func sleep() {
        timer?.invalidate()
        timer = nil
    }
    
    func wake() {
        guard let expirationDate = expirationDate, Date.init() < expirationDate else {
            delegate.timerDid(.expire)
            clear()
            return
        }
        createTimer(withEndTime: expirationDate)
    }
    
    private func createTimer(withEndTime endTime: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: K.hundredthOfASecond, repeats: true) { timer in
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
    }
}
