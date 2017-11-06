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
    private var lastEnteredBackground: Date?
    private let timeout: TimeInterval = 300.0

    private var nav: NavController? {
        return window?.rootViewController as? NavController
    }
    
    private var stopwatchIntermediary: StopwatchIntermediary? {
        return window?.rootViewController as? StopwatchIntermediary
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        lastEnteredBackground = Date()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let date = lastEnteredBackground, timeout < Date().timeIntervalSince(date) {
            nav?.refreshViews()
        }
        lastEnteredBackground = nil
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        stopwatchIntermediary?.killTimer()
    }
}
