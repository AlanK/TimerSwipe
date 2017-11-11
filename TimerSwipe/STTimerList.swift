//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

/// The model on which the app is based
class STTimerList: NSObject, NSCoding {
    /// Array of timers
    private var timers: [STSavedTimer]
    
    // MARK: Initializers
    
    /// Memberwise initializer
    init(timers: [STSavedTimer]) {
        self.timers = timers
        super.init()
        self.validate()
    }
    
    /// Initialize with no timers
    override init() {
        self.timers = [STSavedTimer]()
        super.init()
    }
    
    // MARK: Favorites
    
    /// Toggle favorite status of a specific timer
    func toggleFavorite(at index: Int) {
        switch timers[index].isFavorite {
        case true: timers[index].isFavorite = false
        case false:
            // Remove all existing favorites
            for timer in timers {
                timer.isFavorite = false
            }
            // Mark the timer at the provided index favorite
            timers[index].isFavorite = true
        }
    }
    
    // MARK: Add & Remove
    
    /// Append a timer
    func append(timer: STSavedTimer) {
        timers.append(timer)
        validate()
    }

    /// Replace the existing array of timers with a new array
    private func load(timerArray: [STSavedTimer]) {
        timers = timerArray
        validate()
    }
    
    /// Insert a new timer at a specified index
    func insert(_ newElement: STSavedTimer, at index: Int) {
        timers.insert(newElement, at: index)
        validate()
    }

    /// Remove and return a timer from a specified index
    func remove(at: Int) -> STSavedTimer {
        let timer = timers.remove(at: at)
        return timer
    }
    
    // MARK: Validate
    
    /// Enforce <= 1 favorite timer
    private func validate() {
        guard timers.isEmpty == false else {return}
        var foundAFavorite = false
        for timer in timers {
            switch foundAFavorite {
            // Set flag once a favorite has been found
            case false: if timer.isFavorite {foundAFavorite = true}
            // Once the flag has been set, all other timers must not be favorite
            case true: timer.isFavorite = false
            }
        }
    }
    
    // MARK: Properties
    
    /// Return the timer marked `isFavorite`
    func favorite() -> STSavedTimer? {
        for timer in timers {
            if timer.isFavorite {return timer}
        }
        return nil
    }
    
    func favoriteIndex() -> Int? {
        guard timers.isEmpty == false else {return nil}
        for index in 0..<timers.count {
            if timers[index].isFavorite {return index}
        }
        return nil
    }
    
    func count() -> Int {
        return timers.count
    }
    
    // MARK: Subscript
    
    subscript(index: Int) -> STSavedTimer {
        get {return timers[index]}
        set (newValue) {
            timers[index] = newValue
            validate()
        }
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {aCoder.encode(timers, forKey: K.timersKey)}
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let timers = aDecoder.decodeObject(forKey: K.timersKey) as? [STSavedTimer] else {return nil}
        self.init(timers: timers)
    }    
}

// MARK: - Sample Timers

extension STTimerList {
    /// Set the timer array to a developer-chosen default set of timers
    func loadSampleTimers() {
        load(timerArray: [STSavedTimer(seconds: 60.0), STSavedTimer(seconds: 30.0, isFavorite: true), STSavedTimer(seconds: 15.0)])
    }
}

// MARK: - Save to Disk

extension STTimerList {
    /// Archive the STTimerList
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(persistentList, forKey: K.persistedList)
        print("Saved data!")
    }
}
