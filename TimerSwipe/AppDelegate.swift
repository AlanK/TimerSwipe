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
    
    // Get the model for the rest of the app
    let model = STTimerList.loadExistingModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set the root VC
        let firstVC = RootFC.instantiate(with: model)
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = firstVC
        window!.makeKeyAndVisible()
        
        window!.tintColor = K.tintColor
        
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
        
        guard let launchOptions = launchOptions else { return true }
        guard let shortcutItem = launchOptions[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem else { return false }
        return launchTimer(with: shortcutItem)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let success = launchTimer(with: shortcutItem)
        completionHandler(success)
    }
    
    private func launchTimer(with shortcutItem: UIApplicationShortcutItem) -> Bool {
        let applicationShortcuts = ApplicationShortcuts()
        guard let timer = applicationShortcuts.performActionFor(shortcutItem), let root = window?.rootViewController as? RootFC else { return false }
        root.launchTimer(timer)
        return true
    }
}
