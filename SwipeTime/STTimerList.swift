//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

class STTimerList: NSObject, NSCoding {
    private var timers = [STSavedTimer]()
    
    // MARK: - Initializers
    
    init(timers: [STSavedTimer]) {
        super.init()
        self.timers = timers
        self.validate()
    }
    
    override init() {
        super.init()
        validate()
    }
    
    // MARK: - Favorites
    
    func markFavorite(at index: Int) {
        for timer in timers {
            timer.isFavorite = false
        }
        timers[index].isFavorite = true
    }
    
    func toggleFavorite(at index: Int) {
        switch timers[index].isFavorite {
        case true: timers[index].isFavorite = false
        case false: markFavorite(at: index)
        }
    }
    
    // MARK: - Add
    
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
    
    func insert(_ newElement: STSavedTimer, at index: Int) {
        timers.insert(newElement, at: index)
        validate()
    }

    // MARK: - Remove
    
    func remove(at: Int) -> STSavedTimer {
        let timer = timers.remove(at: at)
        return timer
    }
    
    func clear() {
        timers = [STSavedTimer]()
    }
    
    // MARK: - Validate
    
    func validate() {
        // Confirm there are <= 1 favorites.
        guard timers.isEmpty == false else {return}
        var foundAFavorite = false
        for timer in timers {
            switch foundAFavorite {
            case true: timer.isFavorite = false
            case false: if timer.isFavorite {foundAFavorite = true}
            }
        }
    }
    
    // MARK: - Properties
    
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
    
    required convenience init(coder aDecoder: NSCoder) {
        let timers = aDecoder.decodeObject(forKey: K.timersKey) as! [STSavedTimer]
        self.init(timers: timers)
    }
}

extension STTimerList {
    func loadSampleTimers() {
        self.clear()
        self.append(timerArray: [STSavedTimer(centiseconds: 6000), STSavedTimer(centiseconds: 3000, isFavorite: true), STSavedTimer(centiseconds: 1500)])
    }
}

extension STTimerList {
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(persistentList, forKey: K.persistedList)
        print("Saved data!")
    }
    
    func readData() {
        guard let persistentList = UserDefaults.standard.object(forKey: K.persistedList) else {
            self.loadSampleTimers()
            return
        }
        // This is kind of silly but w/e
        let restoredList = NSKeyedUnarchiver.unarchiveObject(with: persistentList as! Data) as! STTimerList
        while restoredList.count() > 0 {
            self.append(timer: restoredList.remove(at: 0))
        }
        print("Read data!")
    }
}
