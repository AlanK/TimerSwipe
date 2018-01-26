//
//  TimeoutManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/1/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import Foundation

/// Implements a timeout behavior after the background has been in the background for a long time
class TimeoutManager {
    private let timeout: TimeInterval = 300.0

    private var lastEnteredBackground: Date?
    
    private var appStateNotifications = AppStateNotifications()
    
    init(didTimeout: @escaping () -> Void) {
        appStateNotifications.add(onBackground: { [unowned self] in
            self.lastEnteredBackground = Date()
            }, onActive: { [unowned self] in
            if let date = self.lastEnteredBackground, self.timeout < Date().timeIntervalSince(date) {
                didTimeout()
            }
            self.lastEnteredBackground = nil
        })
    }
    
    deinit {
        appStateNotifications.removeAll()
    }
}
