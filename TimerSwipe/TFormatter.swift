//
//  TimeFormatter.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import Foundation

struct TimeFormatter {
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()
    
    func display(time seconds: TimeInterval) -> String {
        return formatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
    
}
