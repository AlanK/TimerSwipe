//
//  TimeoutManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/1/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import Foundation

/// Implements a timeout behavior after the app has been in the background for a long time
class TimeoutManager {
    // MARK: Dependencies
    
    private let timeout: TimeInterval
    private var appStateNotifications: AppStateNotifications

    // MARK: Initializers

    init(_ timeout: TimeInterval = 300.0, appStateNotifications: AppStateNotifications = AppStateNotifications(), didTimeout: @escaping () -> Void) {
        self.timeout = timeout
        self.appStateNotifications = appStateNotifications
        
        monitorTimeout(didTimeout)
    }
    
    deinit { appStateNotifications.removeAll() }

    // MARK: Properties
    
    private var lastEnteredBackground: Date?
    
    // MARK: Methods
    
    private func monitorTimeout(_ didTimeout: @escaping () -> Void) {
        self.appStateNotifications.add(onBackground: { [unowned self] in self.lastEnteredBackground = Date() },
                                       onActive: { [unowned self] in
                                        if let date = self.lastEnteredBackground, self.timeout < Date().timeIntervalSince(date) {
                                            didTimeout()
                                        }
                                        self.lastEnteredBackground = nil
        })
    }
}
