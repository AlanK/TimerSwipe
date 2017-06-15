//
//  TimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeFormatter {
    private let numberFormatter = NumberFormatter()
    private var timeAsString = ["", "", ""]
    private var timeAsInts = [0, 0, 0]
    
    init() {
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
    }
    
    mutating func formatTime(_ time: Int) -> String {
        timeAsInts = [time / K.centisecondsPerMinute, (time / K.centisecondsPerSecond) % K.secondsPerMinute, time % K.centisecondsPerSecond]
        for index in 0...2 {
            timeAsString[index] = numberFormatter.string(from: NSNumber(value: timeAsInts[index])) ?? "00"
        }
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
    }
}
