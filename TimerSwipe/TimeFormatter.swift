//
//  TimeFormatter.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation
/// Formats a time interval for display
struct TimeFormatter {
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()
    /**
     Formats a `TimeInterval` as a `String` for display
     - parameter time: duration of a timer in seconds
     - returns: A string formatted in mm:ss.SS format
     */
    func display(time seconds: TimeInterval) -> String {
        return formatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
    
}
