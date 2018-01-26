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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let applicationShortcuts = ApplicationShortcuts()
        var success = false
        defer { completionHandler(success) }
        
        guard let timer = applicationShortcuts.performActionFor(shortcutItem), let nav = window?.rootViewController as? NavController else { return }
        nav.loadNavigationStack(animated: false, with: timer)
        success = true
    }
}
