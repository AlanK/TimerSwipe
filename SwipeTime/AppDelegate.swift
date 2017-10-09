//
//  AppDelegate.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/24/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    /// Records when the app last entered the background; set to nil after returning to foreground
    private var enteredBackground: Date?
    
    private var timerIsActive: Bool {
        if let nav = window?.rootViewController as? NavController,let timer = nav.topViewController as? StopwatchDelegate,
            timer.unlocked == false {
            return true
        }
        return false
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Don’t start the background timeout if there’s a running timer
        if timerIsActive == false {
            enteredBackground = Date()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Background timeout logic
        defer {
            enteredBackground = nil
        }
        guard let enteredBackground = enteredBackground,
            let nav = window?.rootViewController as? NavController,
            K.timeout < Date().timeIntervalSince(enteredBackground) else {return}
        nav.refreshViews()
    }
}
