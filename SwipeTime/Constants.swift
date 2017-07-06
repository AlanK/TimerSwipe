//
//  Constants.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/9/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

/// Exhaustive list of storyboard segue identifiers
enum SegueID: String {
    case tableToTimer = "tableToTimer"
    case tableToNew = "tableToModal"
}

/// Exhaustive list of storyboard identifiers
enum StoryboardID: String {
    case mainView = "mainView"
    case tableView = "tableView"
    case modalView = "modalView"
}

/// Controls the value of the Change/Cancel button
enum ChangeButtonValue {
    case cancel
    case change
    // rawValue can't return an NSLocalizedString
    /// Returns a localized string with text for the Change/Cancel button
    var text: String {
        switch self {
        case .cancel: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        case .change: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        }
    }
}

/// Audio file names (with extensions)
enum Sound: String {
    case shortWindStart = "TS_short_in.aif"
    case shortWindEnd = "TS_short_out.aif"
    case windStart = "TS_Intro.aif"
    case windEnd = "TS_Outro.aif"
    case legacyStart = "AudioCue_01.aif"
    case legacyEnd = "AudioCue_02.aif"
}

/// Message announcing changes in timer status
enum TimerStatus {
    case start
    case end
    case cancel
}


/// Common constants
struct K {
    
    // MARK: App Appearance
    static let tintColor = UIColor(red: 0.933, green: 0.333, blue: 0.867, alpha: 1.0)
    
    // MARK: App Behavior
    static let timeout: TimeInterval = 300.0
    
    // MARK: Main Table
    static let cellID = "STTableViewCell"
    static let sectionsInTableView = 1
    static let mainSection = 0
    static let editButtonDelay: TimeInterval = 0.5
    
    // MARK: Main View
    static let timerDisplaySize: CGFloat = 64
    static let instructionsAnimationDuration: TimeInterval = 0.2
    static let instructionsShowAlpha: CGFloat = 1.0
    static let instructionsHideAlpha: CGFloat = 0.2
    
    // MARK: Heart Icon
    static let fullHeartIconName = "Full heart"
    static let emptyHeartIconName = "Empty heart"
    
    // MARK: Time
    static let defaultDurationInCentiseconds = 3000
    static let centisecondsPerSecondDouble = 100.0
    static let hundredthOfASecond = 0.01
    
    static let centisecondsPerMinute = 6000
    static let centisecondsPerSecond = 100
    static let secondsPerMinute = 60
    
    // MARK: List Keys
    static let timersKey = "timers"
    static let persistedList = "persistedList"
    
    // MARK: Item Keys
    static let centisecondsKey = "centiseconds"
    static let isFavoriteKey = "isFavorite"
}
