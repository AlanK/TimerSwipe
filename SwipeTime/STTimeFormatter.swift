//
//  STTimeFormatter.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTimeFormatter: NSObject {

    let numberFormatter = NumberFormatter()
    var timeAsString = ["", "", ""]
    
    override init() {
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
    }
    
    func formatTime(_ time: Int) -> (String) {
        
        let timeBlocks = [time / 6000, (time / 100) % 60, time % 100]
        
        for index in 0...2 {
            timeAsString[index] = numberFormatter.string(from: NSNumber(value: timeBlocks[index]))!
        }
        
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
        
    }
    
}
