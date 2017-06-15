//
//  TimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeFormatter {
    let numberFormatter = NumberFormatter()
    
    init() {
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
    }
    
    func formatTime(_ time: Int) -> (String) {
        var timeAsString = [String]()
        let timeBlocks = [time / K.centisecondsPerMinute, (time / K.centisecondsPerSecond) % K.secondsPerMinute, time % K.centisecondsPerSecond]
        
        for index in 0...2 {
            timeAsString.append(numberFormatter.string(from: NSNumber(value: timeBlocks[index])) ?? "00")
        }
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
    }
}
