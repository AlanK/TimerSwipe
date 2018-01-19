//
//  AppStateNotifications.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class AppStateNotifications {
    
    let nc = NotificationCenter.default
    
    let backgroundObserver: NSObjectProtocol, activeObserver: NSObjectProtocol
    
    init(onBackground: @escaping () -> Void, onActive: @escaping () -> Void) {
        backgroundObserver = nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { _ in
            onBackground()
        }
        activeObserver = nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            onActive()
        }
    }
    
    deinit {
        nc.removeObserver(backgroundObserver)
        nc.removeObserver(activeObserver)
    }
}
