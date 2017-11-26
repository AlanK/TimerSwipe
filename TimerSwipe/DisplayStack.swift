//
//  DisplayStack.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

struct DisplayStack {
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()
    
    func display(time seconds: TimeInterval) -> String {
        return timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
    
}
