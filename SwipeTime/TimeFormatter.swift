//
//  TimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Formats a quantity of time into a "00:00.00" string ready to display
struct TimeFormatter {
    // DateFormatter supports hundredths of a second, so we don't have to use NumberFormatter
    private let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "mm:ss.SS"
    }
    
    /// Takes a centisecond integer and returns a string in "00:00.00" format
    func formatTime(_ centiseconds: Int) -> String {
        let timeInterval = Double(centiseconds)/K.centisecondsPerSecondDouble
        return formatTime(timeInterval)
    }
    
    // We're handling time internally using TimeInterval in the hopes of migrating to TimeInterval app-wide in the future.
    /**
     Formats time for display
     
     - parameter time: Time remaining in seconds
     - returns: Time remaining as a string in "00:00.00" format
    */
    func formatTime(_ time: TimeInterval) -> String {
        return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: time))
    }
}
