//
//  TimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeFormatter {
    // Can't use DateComponentsFormatter because we need formatting of hundredths of seconds
    private let numberFormatter = NumberFormatter()
    
    init() {
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
    }
    
    func formatTime(_ centiseconds: Int) -> String {
        var timeAsString = ["", "", ""]
        var integerComponents = [centiseconds / K.centisecondsPerMinute, (centiseconds / K.centisecondsPerSecond) % K.secondsPerMinute, centiseconds % K.centisecondsPerSecond]
        for index in 0...2 {
            timeAsString[index] = numberFormatter.string(from: NSNumber(value: integerComponents[index])) ?? "00"
        }
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
    }
}
