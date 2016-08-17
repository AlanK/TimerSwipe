//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

class STTimerList {
    // Create a singleton instance of this class.
    static let sharedInstance = STTimerList()
    // Ensure no other object can call STTimerList() and bust up the unique nature of the singleton.
    private init() {
        validate()
    }
    
    var timers = [STSavedTimer]()
    let defaultTimer = STSavedTimer()
    
    func favorite() -> STSavedTimer {
        for timer in timers {
            if timer.isFavorite {
                return timer
            }
        }
        return defaultTimer
    }
    
    func validate() {
        // Confirm there are timers and exactly one of them is marked favorite.
        if timers.isEmpty {
            defaultTimer.isFavorite = true
            timers.append(defaultTimer)
        } else {
            var numberOfFavorites = 0
            for timer in timers {
                if numberOfFavorites > 0 {
                    if timer.isFavorite {
                        timer.isFavorite = false
                    }
                } else {
                    if timer.isFavorite {
                        numberOfFavorites += 1
                    }
                }
            }
            if numberOfFavorites == 0 {
                timers[0].isFavorite = true
            }
        }
    }
}
