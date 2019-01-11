//
//  TimeoutManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/1/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

/// Implements a timeout behavior after the app has been in the background for a long time
struct TimeoutManager {
    // MARK: Initializers
    
    init(_ timeout: TimeInterval = 300.0, nc: NotificationCenter = NotificationCenter.default, didTimeout: @escaping () -> Void) {
        
        // Create a background observation that will capture when the app enters the background and create an active observation…
        _ = nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { _ in
            let lastEnteredBackground = Date()
            
            var activeObservation: NSObjectProtocol?
            // … that will check for timeout, initiate the timeout logic, and remove itself from the notification center
            activeObservation = nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
                if timeout < Date().timeIntervalSince(lastEnteredBackground) { didTimeout() }
                nc.removeObserver(activeObservation!)
            }
        }
    }
    
}
