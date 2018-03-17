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
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let firstVC = storyboard.instantiateInitialViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = firstVC
        window!.makeKeyAndVisible()
        
        self.window?.tintColor = K.tintColor
        // Shake-to-undo is too fiddly for a three-digit numbers-only text field, so lets turn it off
        UIApplication.shared.applicationSupportsShakeToEdit = false
        
        guard let launchOptions = launchOptions else { return true }
        guard let shortcutItem = launchOptions[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem else { return false }
        return launchTimer(with: shortcutItem)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let success = launchTimer(with: shortcutItem)
        completionHandler(success)
    }
    
    private func launchTimer(with shortcutItem: UIApplicationShortcutItem) -> Bool {
        let applicationShortcuts = ApplicationShortcuts()
        guard let timer = applicationShortcuts.performActionFor(shortcutItem), let nav = window?.rootViewController as? NavController else { return false }
        nav.loadNavigationStack(animated: false, with: timer)
        return true
    }
}
