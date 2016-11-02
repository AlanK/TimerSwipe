//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

class STTimerList: NSCoding {

    
    var timers = [STSavedTimer]()
    
    // MARK: - Initializers
    
    // Memberwise initializer makes NSCoding support easier.
    
    init(timers: [STSavedTimer]) {
        self.timers = timers
        self.validate()
    }
    
    init() {
        validate()
    }
    
    // MARK: - Methods
    
    func markFavorite(at: Int) {
        for timer in timers {
            timer.isFavorite = false
        }
        timers[at].isFavorite = true
    }
    
    func append(timer: STSavedTimer) {
        timers.append(timer)
        validate()
    }

    func append(timerArray: [STSavedTimer]) {
        for timer in timerArray {
            timers.append(timer)
        }
        validate()
    }

    func remove(at: Int) {
        timers.remove(at: at)
        validate()
    }
    
    func insert(_ newElement: STSavedTimer, at: Int) {
        timers.insert(newElement, at: at)
    }
    
    func validate() {
        // Confirm there are timers and exactly one of them is marked favorite.
        if timers.isEmpty {
            timers.append(STSavedTimer())
        } else {
            var foundAFavorite = false
            for timer in timers {
                if foundAFavorite {
                    timer.isFavorite = false
                } else {
                    if timer.isFavorite {
                        foundAFavorite = true
                    }
                }
            }
            if !foundAFavorite {
                timers[0].isFavorite = true
            }
        }
    }
    
    // MARK: - Properties
    
    func favorite() -> STSavedTimer {
        for timer in timers {
            if timer.isFavorite {
                return timer
            }
        }
        return favorite()
    }
    
    func count() -> Int {
        return timers.count
    }
    
    // MARK: - Subscript
    
    subscript(index: Int) -> STSavedTimer {
        get {
            return timers[index]
        }
        set (newValue) {
            timers[index] = newValue
            validate()
        }
    }
    
    // MARK: - NSCoding
    
    struct PropertyKey {
        static let timersKey = "timers"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timers, forKey: PropertyKey.timersKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let timers = aDecoder.decodeObject(forKey: PropertyKey.timersKey) as! [STSavedTimer]
        
        self.init(timers: timers)
    }
    
}
