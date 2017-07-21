//
//  STSavedTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/8/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

/// Model representation of a user-created timer
class STSavedTimer: NSObject, NSCoding {
    /// Timer duration in seconds
    let seconds: TimeInterval
    /// Whether or not the timer is the user’s favorite
    var isFavorite: Bool
    
    // Memberwise initializer enables NSCoding required convenience initializer
    /// Create a timer of the specified seconds and favorite status
    init(seconds: TimeInterval, isFavorite: Bool) {
        self.seconds = seconds
        self.isFavorite = isFavorite
    }
    
    /// Create a timer of the specified centiseconds
    init(seconds: TimeInterval) {
        self.seconds = seconds
        self.isFavorite = false
    }
    
    /// Create a timer of the default duration
    override convenience init() {
        self.init(seconds: K.defaultDuration)
    }
    
    // MARK: NSCoding
    // This class serializes centiseconds as Int instead of seconds as TimeInterval. This is the result of bad model design when the app was first created and released. For now, centisecond-related legacy code has been quarantined in this part of the app. In the future, the model should be rewritten to serialize seconds as TimeInterval and legacy model objects should be migrated.
    
    func encode(with aCoder: NSCoder) {
        let centisecondsPerSecond = 100.0
        aCoder.encode(Int(seconds*centisecondsPerSecond), forKey: K.centisecondsKey)
        aCoder.encode(isFavorite, forKey: K.isFavoriteKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let centisecondsPerSecond = 100.0
        let centiseconds = aDecoder.decodeInteger(forKey: K.centisecondsKey)
        let isFavorite = aDecoder.decodeBool(forKey: K.isFavoriteKey)
        self.init(seconds: Double(centiseconds)/centisecondsPerSecond, isFavorite: isFavorite)
    }
}
