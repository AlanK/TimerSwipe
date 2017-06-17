//
//  TimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Formats a centisecond integer into a "00:00.00" string ready to display
struct TimeFormatter {
    // Can't use DateComponentsFormatter because we need formatting of hundredths of seconds
    private let numberFormatter = NumberFormatter()
    
    // Format each block of numbers as two digits padded with 0s if necessary
    init() {
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
    }
    
    /// Takes a centisecond integer and returns a string in "00:00.00" format
    func formatTime(_ centiseconds: Int) -> String {
        // Break centisecond integer into [minutes, seconds, hundredths-of-a-second]
        let integerComponents = [centiseconds / K.centisecondsPerMinute, (centiseconds / K.centisecondsPerSecond) % K.secondsPerMinute, centiseconds % K.centisecondsPerSecond]
        // Build string array of [minutes, seconds, hundredths]
        var timeAsString = ["", "", ""]
        for index in 0...2 {
            timeAsString[index] = numberFormatter.string(from: NSNumber(value: integerComponents[index])) ?? "00"
        }
        // Return a string of minutes:seconds.hundredths
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
    }
}
