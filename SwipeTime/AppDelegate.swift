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
    var scheme: String!
    var query: String!
    
    // These don't do anything yet
    var startTimer = false
    var providedTime: Int?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject)-> Bool {
        
        scheme = url.scheme
        query = url.query
        
        guard scheme == "swipetime" else {
            return false
        }
        
        let arguments = query.componentsSeparatedByString("&")
        
        for argument in arguments {
            if argument == "start" {
                
                // This doesn't do anything yet and something else will need to reset startTimer to false.
                startTimer = true
                return true
            }
            
            if argument.hasPrefix("timer=") {
                
                // This is ugly as sin. Can we fix it? Please? It is garbage.
                
                var attemptedValues = argument.componentsSeparatedByString("timer=")
                let value = attemptedValues.removeLast()
                let numberValue = try? Int(value)
                
                if numberValue != nil && numberValue! <= 999 {
                        providedTime = numberValue!
                }
                
                // Make this do something. This doesn't do anything yet. Why is removing a range from a string so hard?
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

