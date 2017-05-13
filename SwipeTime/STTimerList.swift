//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

class STTimerList: NSObject, NSCoding {
    var timers = [STSavedTimer]()
    
    // MARK: - Initializers
    
    // Memberwise initializer makes NSCoding support easier.
    
    init(timers: [STSavedTimer]) {
        super.init()
        self.timers = timers
        self.validate()
    }
    
    override init() {
        super.init()
        validate()
    }
    
    // MARK: - Methods
    
    func markFavorite(at index: Int) {
        for timer in timers {
            timer.isFavorite = false
        }
        timers[index].isFavorite = true
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

    func remove(at: Int) -> STSavedTimer {
        let timer = timers.remove(at: at)
        return timer
        
        // Can't validate here without fucking up rearranging; gotta remove before inserting, so removing the favorite would trigger creation of a new favorite…
    }
    
    func insert(_ newElement: STSavedTimer, at index: Int) {
        timers.insert(newElement, at: index)
        validate()
    }
    
    func validate() {
        // Confirm there are timers and exactly one of them is marked favorite.
        guard timers.isEmpty == false else {
            timers.append(STSavedTimer())
            return
        }
        var foundAFavorite = false
        for timer in timers {
            switch foundAFavorite {
            case true: timer.isFavorite = false
            case false: if timer.isFavorite {foundAFavorite = true}
            }
        }
        
        guard foundAFavorite else {
            timers[0].isFavorite = true
            return
        }
    }
    
    func loadSampleTimers() {
        let timer1 = STSavedTimer(centiseconds: 3000, isFavorite: true)
        let timer2 = STSavedTimer(centiseconds: 2000)
        let timer3 = STSavedTimer(centiseconds: 1000)
        timers = [timer1, timer2, timer3]
    }
    
    // MARK: - Properties
    
    func favorite() -> STSavedTimer {
        for timer in timers {
            if timer.isFavorite {return timer}
        }
        fatalError("Could not find a favorite.")
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
    
    required convenience init(coder aDecoder: NSCoder) {
        let timers = aDecoder.decodeObject(forKey: PropertyKey.timersKey) as! [STSavedTimer]
        self.init(timers: timers)
    }
}
