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
    var enteredBackground: Date?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.tintColor = K.tintColor
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        enteredBackground = Date()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        defer {
            enteredBackground = nil
        }
        guard let enteredBackground = enteredBackground,
            let nav = window?.rootViewController as? NavController,
            K.timeout < Date().timeIntervalSince(enteredBackground) else {return}
        nav.refreshViews()
    }
}

