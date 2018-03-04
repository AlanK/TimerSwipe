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
        // Get every timer marked favorite
        let timersMarkedFavorite = timers.filter { $0.isFavorite == true }
        
        // If there are too many favorites…
        guard timersMarkedFavorite.count > 1 else { return }
        // Create an ArraySlice of the excess favorites
        let excessFavorites = timersMarkedFavorite[1...]
        // Mark the excess favorites isFavorite = false
        _ = excessFavorites.map { $0.isFavorite = false }
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

// MARK: - Update Shortcuts

import UIKit

extension STTimerList {
    private func updateShortcuts() {
        let systemDefinedMaxShortcuts = 4
        let type = ShortcutTypes.timer.rawValue
        let count = timers.count
        
        // If there are no timers, clear all the shortcut items
        guard count > 0 else {
            UIApplication.shared.shortcutItems = nil
            return
        }
        
        // Number of shortcuts can't exceed system max or number of timers
        let logicalMaxShortcuts = count < systemDefinedMaxShortcuts ? count : systemDefinedMaxShortcuts
        let userInfoKey = type
        let icon = UIApplicationShortcutIcon.init(type: UIApplicationShortcutIconType.time)
        
        // Grab just the timers that should have shortcuts
        let timersToUse = timers[..<logicalMaxShortcuts]
        // Create the shortcuts
        let shortcuts = timersToUse.map { timer -> UIApplicationShortcutItem in
            let seconds = Int(timer.seconds)
            let localizedTitle = NSLocalizedString("quickActionTitle", value: "\(seconds)-Second Timer", comment: "A timer of [seconds]-second duration")
            let userInfo = [userInfoKey : seconds]
            
            return UIApplicationShortcutItem.init(type: type, localizedTitle: localizedTitle, localizedSubtitle: nil, icon: icon, userInfo: userInfo)
        }
        // Save the shortcuts
        DispatchQueue.main.async { UIApplication.shared.shortcutItems = shortcuts }
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
        model.updateShortcuts()
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
        updateShortcuts()
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
            return serialQueue.sync {
                timers.index { $0.isFavorite }
            }
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
