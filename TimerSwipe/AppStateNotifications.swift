//
//  AppStateNotifications.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

/// Helps its owner object add and remove notification center observations
struct AppStateNotifications {
    // MARK: Dependencies
    
    private let nc: NotificationCenter
    
    // MARK: Initializers
    
    init(_ nc: NotificationCenter = NotificationCenter.default) { self.nc = nc }
    
    // MARK: Properties
    
    private var backgroundObserver = [NSObjectProtocol](), activeObserver = [NSObjectProtocol]()
    
    // MARK: Methods
    
    mutating func add(onBackground: @escaping () -> Void, onActive: @escaping () -> Void) {
        backgroundObserver.append(nc.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                 object: nil,
                                                 queue: nil,
                                                 using: { _ in onBackground() }))
        
        activeObserver.append(nc.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                             object: nil,
                                             queue: nil,
                                             using: { _ in onActive() }))
    }
    
    mutating func removeAll() {
        backgroundObserver.forEach { nc.removeObserver($0) }
        activeObserver.forEach { nc.removeObserver($0) }
        
        backgroundObserver = []
        activeObserver = []
    }
}
