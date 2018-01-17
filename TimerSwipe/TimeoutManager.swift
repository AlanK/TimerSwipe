//
//  TimeoutManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/1/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import Foundation

/// Implements a timeout behavior after the background has been in the background for a long time
class TimeoutManager: NSObject {
    private let nc = NotificationCenter.default
    private let timeout: TimeInterval = 300.0

    private var lastEnteredBackground: Date?
    
    init(didTimeout: @escaping () -> Void) {
        super.init()
        
        nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [unowned self] _ in
            self.lastEnteredBackground = Date()
        }
        nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [unowned self] _ in
            if let date = self.lastEnteredBackground, self.timeout < Date().timeIntervalSince(date) {
                didTimeout()
            }
            self.lastEnteredBackground = nil
        }
    }
    
    deinit {
        nc.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        nc.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
}
