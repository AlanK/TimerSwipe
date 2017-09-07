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
    var enteredBackground: Date?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Background timeout start time
        enteredBackground = Date()
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
