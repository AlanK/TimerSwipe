//
//  ApplicationShortcuts.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/26/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ApplicationShortcuts {
    let systemDefinedMaxShortcuts = 4
    let type = ShortcutTypes.timer.rawValue

    var existingShortcuts: [UIApplicationShortcutItem]? {
        get { return UIApplication.shared.shortcutItems }
    }
    
    // It might be nice if the model and this object shared a serial queue to move a bunch of work off the main thread…
    
    func updateShortcuts(from timerList: STTimerList) {
        let count = timerList.count()
        
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
            let timer = timerList[index]
            let seconds = Int(timer.seconds)
            let localizedTitle = NSLocalizedString("quickActionTitle", value: "\(seconds)-Second Timer", comment: "A timer of [seconds]-second duration")
            let userInfo = [userInfoKey : seconds]

            let shortcut = UIApplicationShortcutItem.init(type: type, localizedTitle: localizedTitle, localizedSubtitle: nil, icon: icon, userInfo: userInfo)
            newShortcuts.append(shortcut)
        }
        UIApplication.shared.shortcutItems = newShortcuts
    }
    
    func performActionFor(_ shortcut: UIApplicationShortcutItem) -> STSavedTimer? {
        guard shortcut.type == type, let seconds = shortcut.userInfo?[type] as? Int else { return nil }
        let timeInterval = Double(seconds)
        let timer = STSavedTimer.init(seconds: timeInterval)
        return timer
    }
}
