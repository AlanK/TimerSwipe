//
//  Stopwatch.swift
//  SwipeTime
//
//  Created by Alan Kantz on 5/13/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

enum ChangeButtonValue {
    case cancel
    case change
    
    var text: String {
        switch self {
        case .cancel: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        case .change: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        }
    }
}

protocol StopwatchDelegate {
    var unlocked: Bool {get}

    func updateDisplay(with: Int)
    
    func timerDidStart()
    func timerDidEnd()
    func timerDidCancel()
    
    func lock()
    func unlock()
}

struct Stopwatch {
    private let delegate: StopwatchDelegate
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
        delegate.timerDidStart()
    }
    
    private func tick(_ timer: Timer, until endTime: Date) {
        guard delegate.unlocked == false else {
            clear(timer: timer)
            delegate.timerDidCancel()
            return
        }
        let currentTime = Date.init()
        guard currentTime < endTime else {
            clear(timer: timer)
            delegate.timerDidEnd()
            return
        }
        let timeRemaining = Int(endTime.timeIntervalSince(currentTime) * K.centisecondsPerSecondDouble)
        delegate.updateDisplay(with: timeRemaining)
    }
    
    func clear(timer: Timer? = nil) {
        timer?.invalidate()
        delegate.unlock()
        delegate.updateDisplay(with: duration)
    }

}
