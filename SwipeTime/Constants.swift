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
}

/// Exhaustive list of storyboard identifiers
enum StoryboardID: String {
    case mainView = "mainView"
    case tableView = "tableView"
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
    static let tintColor = UIColor(red: 255.0/255.0, green: 35.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    static let fineLineColor = UIColor(white: 2.0/3.0, alpha: 1.0)
    static let largeFont = UIFont.preferredFont(forTextStyle: .title1)

    // MARK: Main Table
    static let editButtonDelay: TimeInterval = 0.5
    
    // MARK: Main View
    static let timerDisplaySize: CGFloat = 64
    static let instructionsAnimationDuration: TimeInterval = 0.2
    static let enabledAlpha: CGFloat = 1.0
    static let disabledAlpha: CGFloat = 0.2
    
    // MARK: Heart Icon
    static let fullHeartIconName = "Full heart"
    static let emptyHeartIconName = "Empty heart"
    
    // MARK: Time
    static let defaultDuration: TimeInterval = 30.0
    static let hundredthOfASecond: TimeInterval = 0.01
    
    // MARK: List Keys
    static let timersKey = "timers"
    static let persistedList = "persistedList"
    
    // MARK: Item Keys
    static let centisecondsKey = "centiseconds"
    static let isFavoriteKey = "isFavorite"
}
