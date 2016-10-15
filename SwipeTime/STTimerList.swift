//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

class STTimerList {

    
    var timers = [STSavedTimer]()
    var defaultTimer = STSavedTimer()

    init () {
        validate()
    }
    
    func favorite() -> STSavedTimer {
        for timer in timers {
            if timer.isFavorite {
                return timer
            }
        }
        validate()
        return favorite()
    }
    
    func append (_ timer: STSavedTimer) {
        timers.append(timer)
        validate()
    }
    
    func count () -> Int {
        return timers.count
    }
    
    func append (_ timerArray: [STSavedTimer]) {
        for timer in timerArray {
            timers.append(timer)
        }
        validate()
    }
    
    subscript(index: Int) -> STSavedTimer {
        get {
            return timers[index]
        }
        set (newValue) {
            timers[index] = newValue
        }
    }
    
    func remove(at: Int) {
        timers.remove(at: at)
        validate()
    }
    
    func validate () {
        // Confirm there are timers and exactly one of them is marked favorite.
        if timers.isEmpty {
            timers.append(defaultTimer)
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
}
