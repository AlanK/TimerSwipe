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
    case expire
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

extension UIButton {
    func lightButtonStyle() {
        titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        
        let vInset: CGFloat = 8.0, hInset: CGFloat = 16.0
        contentEdgeInsets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset)
        
        layer.cornerRadius = 6.0
        tintColor = K.tintColor
        
        backgroundColor = .white
    }
}

/// Common constants
struct K {
    
    // MARK: App Appearance
    static let tintColor = UIColor(red: 255.0/255.0, green: 35.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    static let fineLineColor = UIColor(white: 2.0/3.0, alpha: 1.0)
    static let largeFont = UIFont.preferredFont(forTextStyle: .title1)
    static let mediumFont = UIFont.preferredFont(forTextStyle: .title3)

    // MARK: Main Table
    static let editButtonDelay: TimeInterval = 0.5
    
    // MARK: Main View
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
    
    // MARK: Notification Keys
    static let notificationID = "TimerComplete"
}
