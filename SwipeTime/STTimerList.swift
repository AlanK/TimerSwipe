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
    private var timers = [STSavedTimer]()
    
    // MARK: - Initializers
    
    /// Memberwise initializer
    init(timers: [STSavedTimer]) {
        super.init()
        self.timers = timers
        self.validate()
    }
    
    /// Initialize with no timers
    override init() {
        super.init()
    }
    
    // MARK: - Favorites
    
    /// Mark a specific timer favorite
    func markFavorite(at index: Int) {
        // Remove all existing favorites
        for timer in timers {
            timer.isFavorite = false
        }
        // Mark the timer at the provided index favorite
        timers[index].isFavorite = true
    }
    
    /// Toggle favorite status of a specific timer
    func toggleFavorite(at index: Int) {
        switch timers[index].isFavorite {
        // When unfavoriting a timer, just do it
        case true: timers[index].isFavorite = false
        // When favoriting a timer, make sure to validate
        case false: markFavorite(at: index)
        }
    }
    
    // MARK: - Add
    
    /// Append a timer
    func append(timer: STSavedTimer) {
        timers.append(timer)
        validate()
    }

    /// Append an array of timers
    func append(timerArray: [STSavedTimer]) {
        for timer in timerArray {
            timers.append(timer)
        }
        validate()
    }
    
    /// Replace the existing array of timers with a new array
    func load(timerArray: [STSavedTimer]) {
        clear()
        append(timerArray: timerArray)
    }
    
    /// Insert a new timer at a specified index
    func insert(_ newElement: STSavedTimer, at index: Int) {
        timers.insert(newElement, at: index)
        validate()
    }

    // MARK: - Remove
    
    /// Remove and return a timer from a specified index
    func remove(at: Int) -> STSavedTimer {
        let timer = timers.remove(at: at)
        return timer
    }
    
    /// Replace the current array of timers with an empty array
    func clear() {
        timers = [STSavedTimer]()
    }
    
    // MARK: - Validate
    
    /// Enforce <= 1 favorite timer
    func validate() {
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
    
    // MARK: - Properties
    
    /// Return the timer marked `isFavorite`
    func favorite() -> STSavedTimer? {
        for timer in timers {
            if timer.isFavorite {return timer}
        }
        return nil
    }
    
    func count() -> Int {
        return timers.count
    }
    
    // MARK: - Subscript
    
    subscript(index: Int) -> STSavedTimer {
        get {return timers[index]}
        set (newValue) {
            timers[index] = newValue
            validate()
        }
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {aCoder.encode(timers, forKey: K.timersKey)}
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let timers = aDecoder.decodeObject(forKey: K.timersKey) as? [STSavedTimer] else {return nil}
        self.init(timers: timers)
    }    
}

extension STTimerList {
    /// Set the timer array to a developer-chosen default set of timers
    func loadSampleTimers() {
        load(timerArray: [STSavedTimer(centiseconds: 6000), STSavedTimer(centiseconds: 3000, isFavorite: true), STSavedTimer(centiseconds: 1500)])
    }
}

extension STTimerList {
    /// Archive the STTimerList
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(persistentList, forKey: K.persistedList)
        print("Saved data!")
    }
}
