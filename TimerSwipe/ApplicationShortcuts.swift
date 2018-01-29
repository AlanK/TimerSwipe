//
//  ApplicationShortcuts.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/26/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ApplicationShortcuts {
    let type = ShortcutTypes.timer.rawValue

    var existingShortcuts: [UIApplicationShortcutItem]? {
        get { return UIApplication.shared.shortcutItems }
    }
    
    func performActionFor(_ shortcut: UIApplicationShortcutItem) -> STSavedTimer? {
        guard shortcut.type == type, let seconds = shortcut.userInfo?[type] as? Int else { return nil }
        let timeInterval = Double(seconds)
        let timer = STSavedTimer.init(seconds: timeInterval)
        return timer
    }
}
