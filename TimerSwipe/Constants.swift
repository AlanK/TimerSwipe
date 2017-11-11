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

extension UIView {
    /// Recursively find and return the topmost superview
    var supremeView: UIView {
        func getSupremeView(of view: UIView) -> UIView {
            guard let superview = view.superview else {return view}
            return getSupremeView(of: superview)
        }
        
        return getSupremeView(of: self)
    }
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
    
    // MARK: Keyboard Animation
    static let keyboardAnimationDuration: TimeInterval = 1.0/3.0
    static let keyboardAnimateInCurve: UIViewAnimationOptions = .curveEaseOut
    static let keyboardAnimateOutCurve: UIViewAnimationOptions = .curveEaseInOut
    
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