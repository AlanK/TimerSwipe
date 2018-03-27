//
//  Constants.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/9/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

/// Exhaustive list of storyboards
enum Storyboards: String {
    case main = "Main"
    case permissions = "Permissions"
}

/// Exhaustive list of main storyboard identifiers
enum MainID: String {
    case mainView = "mainView"
    case tableView = "tableView"
}

/// Exhaustive list of permissions storyboard identifiers
enum PermissionsID: String {
    case permissionController = "PermissionController"
}

/// Valid types for `UIApplicationShortcutItem`
enum ShortcutTypes: String {
    case timer = "timer"
}

extension UIViewController {
    func addChild(_ childVC: UIViewController, to view: UIView) {
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        
        childVC.didMove(toParentViewController: self)
    }
    
    func addChildToRootView(_ childVC: UIViewController) {
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = view.bounds
        childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childVC.didMove(toParentViewController: self)
    }
    
    /// Remove this view controller from a parent view controller
    func remove() {
        guard let _ = parent else { return }
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
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

extension UINavigationController {
    static func instantiateWithTSStyle() -> UINavigationController {
        let nc = UINavigationController()
        
        nc.navigationBar.barStyle = .black
        nc.navigationBar.barTintColor = K.tintColor
        nc.navigationBar.tintColor = .white
        if #available(iOS 11.0, *) { nc.navigationBar.prefersLargeTitles = true }
        
        return nc
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
    static let smallAmountOfTime: TimeInterval = 9.0
    
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
    
    // MARK: Announcment Keys
    static let announcementKey = "announce"
}
