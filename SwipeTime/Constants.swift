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

/// Common constants
struct K {
    
    // MARK: App Appearance
    
    static let tintColor = UIColor(red: 0.8, green: 0.3, blue: 0.8, alpha: 1.0)
    
    // MARK: Main Table
    
    static let cellID = "STTableViewCell"
    static let sectionsInTableView = 1
    static let mainSection = 0
    
    // MARK: Main View
    
    static let timerDisplaySize: CGFloat = 64
    
    // MARK: Heart Icon
    
    static let fullHeart = "Full heart"
    static let emptyHeart = "Empty heart"
    
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
