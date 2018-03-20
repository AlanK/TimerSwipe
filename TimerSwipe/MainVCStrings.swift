//
//  MainVCStrings.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/26/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

struct MainVCStrings {
    // Localized strings for CountdownDelegate events
    let timerStarted = NSLocalizedString("Started timer, double-tap to cancel",
                                         comment: "The timer has started, double-tap on the screen to cancel it"),
    timerEnded = NSLocalizedString("Timer finished",
                                   comment: "The timer has finished"),
    timerCancelled = NSLocalizedString("Cancelled timer",
                                       comment: "The timer has been cancelled")
    
    /// Returns a localized string with text for the Change/Cancel button
    func buttonText(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("changeButton",
                                            value: "Change",
                                            comment: "Change which timer is displayed")
        case false: return NSLocalizedString("cancelButton",
                                             value: "Cancel",
                                             comment: "Cancel the timer that is currently running")
        }
    }
    
    /// Returns a localized string with VoiceOver instructions for the Change/Cancel button
    func buttonLabel(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("Change timer",
                                            comment: "Change the timer by selecting another one")
        case false: return NSLocalizedString("Cancel timer",
                                             comment: "Cancel the running timer")
        }
    }
    
    /**
     Text for visible instructions depending on VoiceOver Status
     - parameter voiceOverOn: the status of VoiceOver
     - returns: instructions to display to the user
     */
    func textInstructions(voiceOverIsOn: Bool) -> String {
        switch voiceOverIsOn {
        case true: return NSLocalizedString("Double-Tap to Start",
                                            comment: "Double-tap anywhere on the screen to start the timer")
        case false: return NSLocalizedString("Swipe to Start",
                                             comment: "Swipe anywhere on the screen in any direction to start the timer")
        }
    }
    
}
