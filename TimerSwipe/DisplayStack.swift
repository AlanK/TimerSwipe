//
//  DisplayStack.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

struct DisplayStack {
    static let timerStarted = NSLocalizedString("timerStarted", value: "Started timer, double-tap to cancel", comment: "The timer has started, double-tap anywhere on the screen to cancel the running timer"),
    timerEnded = NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"),
    timerCancelled = NSLocalizedString("timerCancelled", value: "Cancelled timer", comment: "The timer has been cancelled")
    
    static func textInstructions(voiceOverOn: Bool) -> String {
        return voiceOverOn ? NSLocalizedString("doubleTapToStart", value: "Double-Tap to Start", comment: "Double-tap anywhere on the screen to start the timer") : NSLocalizedString("swipeToStart", value: "Swipe to Start", comment: "Swipe anywhere on the screen in any direction to start the timer")
    }
    
    static func containerViewLabel(timerReady: Bool, timerDuration: TimeInterval) -> String {
        let textDuration = String(Int(timerDuration))
        return timerReady ? NSLocalizedString("timerReady", value: "\(textDuration)-second timer, starts timer", comment: "{Whole number}-second timer (When activated, this button) starts the timer") : NSLocalizedString("runningTimer", value: "Running \(textDuration)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()
    
    func display(time seconds: TimeInterval) -> String {
        return timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
    
}
