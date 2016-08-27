//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

class STTimerList {

    
    var timers = [STSavedTimer]()
    let defaultTimer = STSavedTimer()

    init () {
        validate()
    }
    
    func favorite() -> STSavedTimer {
        for timer in timers {
            if timer.isFavorite {
                return timer
            }
        }
        return defaultTimer
    }
    
    func append (timer: STSavedTimer) {
        timers.append(timer)
    }
    
    func count () -> Int {
        return timers.count
    }
    
    func append (timerArray: [STSavedTimer]) {
        for timer in timerArray {
            timers.append(timer)
        }
    }
    
    subscript(index: Int) -> STSavedTimer {
        get {
            return timers[index]
        }
        set (newValue) {
            timers[index] = newValue
        }
    }
    
    func validate () {
        // Confirm there are timers and exactly one of them is marked favorite.
        if timers.isEmpty {
            defaultTimer.isFavorite = true
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
