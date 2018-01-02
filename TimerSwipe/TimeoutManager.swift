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

    private let didTimeout: (() -> Void), willTerminate: (() -> Void)
    
    private var lastEnteredBackground: Date?
    
    var isEnabled: Bool = false {
        willSet {
            if newValue == true {
                nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) {_ in
                    self.lastEnteredBackground = Date()
                }
                nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) {_ in
                    if let date = self.lastEnteredBackground, self.timeout < Date().timeIntervalSince(date) {
                        self.didTimeout()
                    }
                    self.lastEnteredBackground = nil
                }
                nc.addObserver(forName: .UIApplicationWillTerminate, object: nil, queue: nil) {_ in
                    self.willTerminate()
                }
            } else {
                nc.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
                nc.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
                nc.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
            }
        }
    }
    
    init(didTimeout: @escaping () -> Void, willTerminate: @escaping () -> Void) {
        self.didTimeout = didTimeout
        self.willTerminate = willTerminate
    }
    
    deinit {
        self.isEnabled = false
    }
}
