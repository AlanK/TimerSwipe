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
    // Timer duration in seconds
    let seconds: TimeInterval
    // Whether or not the timer is the user’s favorite
    var isFavorite: Bool
    
    // Memberwise initializer enables NSCoding required convenience initializer
    /// Create a timer of the specified centiseconds and favorite status
    private init(centiseconds: Int, isFavorite: Bool) {
        self.seconds = Double(centiseconds)/K.centisecondsPerSecondDouble
        self.isFavorite = isFavorite
    }
    
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
        self.init(seconds: Double(K.defaultDurationInCentiseconds)/K.centisecondsPerSecondDouble)
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Int(seconds)*K.centisecondsPerSecond, forKey: K.centisecondsKey)
        aCoder.encode(isFavorite, forKey: K.isFavoriteKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let centiseconds = aDecoder.decodeInteger(forKey: K.centisecondsKey)
        let isFavorite = aDecoder.decodeBool(forKey: K.isFavoriteKey)
        self.init(centiseconds: centiseconds, isFavorite: isFavorite)
    }
}
