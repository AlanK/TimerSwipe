//
//  MainVCStrings.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/26/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

struct MainVCStrings {
    // Localized strings for StopwatchDelegate events
    let timerStarted = NSLocalizedString("timerStarted", value: "Started timer, double-tap to cancel", comment: "The timer has started, double-tap anywhere on the screen to cancel the running timer"),
    timerEnded = NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"),
    timerCancelled = NSLocalizedString("timerCancelled", value: "Cancelled timer", comment: "The timer has been cancelled")
    
    /// Returns a localized string with text for the Change/Cancel button
    func buttonText(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        case false: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        }
    }
    
    /// Returns a localized string with VoiceOver instructions for the Change/Cancel button
    func buttonLabel(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("changeTimer", value: "Change timer", comment: "Change the timer by selecting another one")
        case false: return NSLocalizedString("cancelTimer", value: "Cancel timer", comment: "Cancel the running timer")
        }
    }
    
    /**
     Text for visible instructions depending on VoiceOver Status
     - parameter voiceOverOn: the status of VoiceOver
     - returns: instructions to display to the user
     */
    func textInstructions(voiceOverIsOn: Bool) -> String {
        switch voiceOverIsOn {
        case true:
            return NSLocalizedString("doubleTapToStart", value: "Double-Tap to Start", comment: "Double-tap anywhere on the screen to start the timer")
        case false:
            return NSLocalizedString("swipeToStart", value: "Swipe to Start", comment: "Swipe anywhere on the screen in any direction to start the timer")
        }
    }
    
    /**
     Spoken instructions based on timer status and duration
     - parameter timerReady: the status of the timer
     - parameter timerDuration: the duration of the timer
     - returns: VoiceOver instructions for the user
     */
    func containerViewLabel(timerReady: Bool, timerDuration: TimeInterval) -> String {
        let textDuration = String(Int(timerDuration))
        switch timerReady {
        case true:
            return NSLocalizedString("timerReady", value: "\(textDuration)-second timer, starts timer", comment: "{Whole number}-second timer (When activated, this button) starts the timer")
        case false:
            return NSLocalizedString("runningTimer", value: "Running \(textDuration)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
        }
    }
}