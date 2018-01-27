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
    private let applicationShortcuts = ApplicationShortcuts()
    
    private let serialQueue = DispatchQueue.init(label: "serialQueue", qos: .userInitiated)
    
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
    
    /// Toggle favorite status of a specific timer and return an array of all timers with favorite status changed
    func updateFavorite(at index: Int) -> [Int] {
        var updatedTimers = [index]
        
        serialQueue.sync {
            switch timers[index].isFavorite {
            case true: timers[index].isFavorite = false
            case false:
                for i in 0..<timers.count {
                    if timers[i].isFavorite {
                        timers[i].isFavorite = false
                        updatedTimers.append(i)
                    }
                }
                timers[index].isFavorite = true
            }
        }
        
        return updatedTimers
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
    
    /// Insert an array of timers at a specified index
    func insert(_ newTimers: [STSavedTimer], at index: Int) {
        timers.insert(contentsOf: newTimers, at: index)
        validate()
    }

    /// Remove and return a timer from a specified index
    func remove(at: Int) -> STSavedTimer {
        var timer: STSavedTimer!
        
        serialQueue.sync { timer = timers.remove(at: at) }
        
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
        var favorite: STSavedTimer?
        
        serialQueue.sync {
            for timer in timers {
                if timer.isFavorite {
                    favorite = timer
                    break
                }
            }
        }
        
        return favorite
    }
    
    func favoriteIndex() -> Int? {
        var favoriteIndex: Int?
        
        serialQueue.sync {
            guard timers.isEmpty == false else { return }
            for index in 0..<timers.count {
                if timers[index].isFavorite { favoriteIndex = index }
            }
        }
        
        return favoriteIndex
    }
    
    func count() -> Int {
        var count: Int!
        
        serialQueue.sync { count = timers.count }
        
        return count
    }
    
    // MARK: Subscript
    
    subscript(index: Int) -> STSavedTimer {
        get {
            var savedTimer: STSavedTimer!
            
            serialQueue.sync { savedTimer = timers[index] }
            
            return savedTimer
        }
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
    
    static func loadExistingModel() -> STTimerList {
        let model: STTimerList
        // Try to load the model from UserDefaults
        if let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data, let extractedModel = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList {
            model = extractedModel
        } else {
            // No model extracted; give up and load the default model
            model = STTimerList()
            model.loadSampleTimers()
        }
        // Update the application shortcuts in case this is the first time we're running a version that supports application shortcuts
        model.applicationShortcuts.updateShortcuts(from: model)

        return model
    }
}

// MARK: - Save to Disk

extension STTimerList {
    /// Archive the STTimerList
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(persistentList, forKey: K.persistedList)
        applicationShortcuts.updateShortcuts(from: self)
        print("Saved data!")
    }
}
