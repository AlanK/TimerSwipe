//
//  STTimerList.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

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

/// The model on which the app is based
class STTimerList: NSObject, NSCoding {
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
        serialQueue.async {
            self.timers.append(timer)
            self.validate()
        }
    }

    /// Replace the existing array of timers with a new array
    private func load(timerArray: [STSavedTimer]) {
        serialQueue.async {
            self.timers = timerArray
            self.validate()
        }
    }
    
    /// Insert a new timer at a specified index
    func insert(_ newElement: STSavedTimer, at index: Int) {
        serialQueue.async {
            self.timers.insert(newElement, at: index)
            self.validate()
        }
    }
    
    /// Insert an array of timers at a specified index
    func insert(_ newTimers: [STSavedTimer], at index: Int) {
        serialQueue.async {
            self.timers.insert(contentsOf: newTimers, at: index)
            self.validate()
        }
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
        serialQueue.async {
            guard self.timers.isEmpty == false else { return }
            var foundAFavorite = false
            for timer in self.timers {
                switch foundAFavorite {
                // Set flag once a favorite has been found
                case false: if timer.isFavorite { foundAFavorite = true }
                // Once the flag has been set, all other timers must not be favorite
                case true: timer.isFavorite = false
                }
            }
        }
    }
    
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
    
    // MARK: Subscript
    
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
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        // Be careful about where you call this
        aCoder.encode(self.timers, forKey: K.timersKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let timers = aDecoder.decodeObject(forKey: K.timersKey) as? [STSavedTimer] else {return nil}
        self.init(timers: timers)
    }    
}

// MARK: - Update Shortcuts

import UIKit

extension STTimerList {
    private func updateShortcuts() {
        serialQueue.async {
            let systemDefinedMaxShortcuts = 4
            let type = ShortcutTypes.timer.rawValue
            let count = self.timers.count
            
            // If there are no timers, clear all the shortcut items
            guard count > 0 else {
                UIApplication.shared.shortcutItems = nil
                return
            }
            
            // Number of shortcuts can't exceed system max or number of timers
            let logicalMaxShortcuts = count < systemDefinedMaxShortcuts ? count : systemDefinedMaxShortcuts
            let userInfoKey = type
            let icon = UIApplicationShortcutIcon.init(type: UIApplicationShortcutIconType.time)
            
            var newShortcuts = [UIApplicationShortcutItem]()
            
            // Create the shortcut and add it to the newShortcuts array
            for index in 0..<logicalMaxShortcuts {
                let timer = self.timers[index]
                let seconds = Int(timer.seconds)
                let localizedTitle = NSLocalizedString("quickActionTitle", value: "\(seconds)-Second Timer", comment: "A timer of [seconds]-second duration")
                let userInfo = [userInfoKey : seconds]
                
                let shortcut = UIApplicationShortcutItem.init(type: type, localizedTitle: localizedTitle, localizedSubtitle: nil, icon: icon, userInfo: userInfo)
                newShortcuts.append(shortcut)
            }
            DispatchQueue.main.async {
                UIApplication.shared.shortcutItems = newShortcuts
            }
        }
    }
}

// MARK: - Sample Timers

extension STTimerList {
    /// Set the timer array to a developer-chosen default set of timers
    private func loadSampleTimers() {
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
        model.updateShortcuts()

        return model
    }
}

// MARK: - Save to Disk

extension STTimerList {
    /// Archive the STTimerList
    func saveData() {
        serialQueue.async {
            let persistentList = NSKeyedArchiver.archivedData(withRootObject: self)
            UserDefaults.standard.set(persistentList, forKey: K.persistedList)
            print("Saved data!")
            self.updateShortcuts()
        }
    }
}

extension STTimerList: Model {
    
}
