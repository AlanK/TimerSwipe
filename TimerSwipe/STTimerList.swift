//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

// MARK: Model Protocol
/// Model is a threadsafe abstraction `for STTimerList`
protocol Model {
    subscript(index: Int) -> STSavedTimer { get set }

    var favorite: STSavedTimer? { get }
    var favoriteIndex: Int? { get }
    var count: Int { get }

    func updateFavorite(at: Int) -> [Int]
    func append(timer: STSavedTimer)
    func insert(_: STSavedTimer, at: Int)
    func insert(_: [STSavedTimer], at: Int)
    func remove(at: Int) -> STSavedTimer
    func saveData()
}

// MARK: - Timer List
/// The model on which the app is based
class STTimerList: NSObject, NSCoding {
    /// Serial queue upon which all reads and writes occur when going through the Model protocol conformance extension
    private let serialQueue: DispatchQueue
    
    private let applicationShortcuts = ApplicationShortcuts()
    
    /// Array of timers
    private var timers: [STSavedTimer]
    
    // MARK: Initializers
    
    /// Memberwise initializer
    init(timers: [STSavedTimer] = [STSavedTimer](), serialQueue: DispatchQueue = DispatchQueue.init(label: "serialQueue", qos: .userInitiated)) {
        self.timers = timers
        self.serialQueue = serialQueue
        super.init()
        self.validate()
    }
    
    // MARK: Favorites
    /// Toggle favorite status of a specific timer and return an array of all timers with favorite status changed
    private func internalUpdateFavorite(at index: Int) -> [Int] {
        var updatedTimers = [index]
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
        return updatedTimers
    }
    
    // MARK: Add & Remove
    /// Append a timer
    private func internalAppend(timer: STSavedTimer) {
        timers.append(timer)
        validate()
    }

    /// Insert a new timer at a specified index
    private func internalInsert(_ newElement: STSavedTimer, at index: Int) {
        timers.insert(newElement, at: index)
        validate()
    }
    
    /// Insert an array of timers at a specified index
    private func internalInsert(_ newTimers: [STSavedTimer], at index: Int) {
        timers.insert(contentsOf: newTimers, at: index)
        validate()
    }

    /// Remove and return a timer from a specified index
    private func internalRemove(at index: Int) -> STSavedTimer {
        return timers.remove(at: index)
    }
    
    // MARK: Validate
    
    /// Enforce <= 1 favorite timer
    private func validate() {
        guard timers.isEmpty == false else { return }
        var foundAFavorite = false
        for timer in timers {
            switch foundAFavorite {
            // Set flag once a favorite has been found
            case false: if timer.isFavorite { foundAFavorite = true }
            // Once the flag has been set, all other timers must not be favorite
            case true: timer.isFavorite = false
            }
        }
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        // Be careful about where you call this
        aCoder.encode(self.timers, forKey: K.timersKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let timers = aDecoder.decodeObject(forKey: K.timersKey) as? [STSavedTimer] else { return nil }
        self.init(timers: timers)
    }    
}

// MARK: - Load

extension STTimerList {
    static func loadExistingModel() -> Model {
        let model: STTimerList
        // Try to load the model from UserDefaults
        if let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data, let extractedModel = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList {
            model = extractedModel
        } else {
            // No model extracted; give up and load the default model
            model = STTimerList.init(timers: [STSavedTimer(seconds: 60.0), STSavedTimer(seconds: 30.0, isFavorite: true), STSavedTimer(seconds: 15.0)])
        }
        // Update the application shortcuts in case this is the first time we're running a version that supports application shortcuts
        model.applicationShortcuts.updateShortcuts(with: model)
        return model
    }
}

// MARK: - Save to Disk
extension STTimerList {
    /// Archive the STTimerList
    private func internalSaveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(persistentList, forKey: K.persistedList)
        print("Saved data!")
        applicationShortcuts.updateShortcuts(with: self)
    }
}

// MARK: - Model Conformance
extension STTimerList: Model {
    // MARK: Properties
    /// Return the timer marked `isFavorite`
    var favorite: STSavedTimer? {
        get {
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
    }
    
    var favoriteIndex: Int? {
        get {
            var favoriteIndex: Int?
            serialQueue.sync {
                guard timers.isEmpty == false else { return }
                for index in 0..<timers.count {
                    if timers[index].isFavorite { favoriteIndex = index }
                }
            }
            return favoriteIndex
        }
    }
    
    var count: Int {
        get {
            var count: Int!
            serialQueue.sync { count = timers.count }
            return count
        }
    }
    
    // MARK: Methods
    
    func saveData() {
        serialQueue.async { self.internalSaveData() }
    }
    
    func insert(_ newTimers: [STSavedTimer], at index: Int) {
        serialQueue.async { self.internalInsert(newTimers, at: index) }
    }
    
    func insert(_ newElement: STSavedTimer, at index: Int) {
        serialQueue.async { self.internalInsert(newElement, at: index) }
    }
    
    func updateFavorite(at index: Int) -> [Int] {
        var indicesOfChangedTimers: [Int]!
        serialQueue.sync { indicesOfChangedTimers = internalUpdateFavorite(at: index) }
        return indicesOfChangedTimers
    }
    
    func append(timer: STSavedTimer) {
        serialQueue.async { self.internalAppend(timer: timer) }
    }
    
    func remove(at index: Int) -> STSavedTimer {
        var removedTimer: STSavedTimer!
        serialQueue.sync { removedTimer = internalRemove(at: index) }
        return removedTimer
    }
    
    subscript(index: Int) -> STSavedTimer {
        get {
            var savedTimer: STSavedTimer!
            serialQueue.sync { savedTimer = timers[index] }
            return savedTimer
        }
        set (newValue) {
            serialQueue.async {
                self.timers[index] = newValue
                self.validate()
            }
        }
    }
}
