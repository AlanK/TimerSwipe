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
    private let timeout: TimeInterval = 300.0

    private var nav: NavController? {
        return window?.rootViewController as? NavController
    }
    
    func killTimer() {
        nav?.killTimer()
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        enteredBackground = Date()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Background timeout logic
        defer {
            enteredBackground = nil
        }
        guard let enteredBackground = enteredBackground,
            timeout < Date().timeIntervalSince(enteredBackground) else {return}
        nav?.refreshViews()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        killTimer()
    }
}
