//
//  AppStateNotifications.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct AppStateNotifications {
    let nc = NotificationCenter.default
    
    var backgroundObserver = [NSObjectProtocol](), activeObserver = [NSObjectProtocol]()
    
    mutating func add(onBackground: @escaping () -> Void, onActive: @escaping () -> Void) {
        backgroundObserver.append(nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { _ in
            onBackground()
        })
        activeObserver.append(nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            onActive()
        })
    }
    
    func removeAll() {
        for observer in backgroundObserver {
            nc.removeObserver(observer)
        }
        for observer in activeObserver {
            nc.removeObserver(observer)
        }
    }
}
