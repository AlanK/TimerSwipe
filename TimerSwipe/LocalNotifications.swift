//
//  LocalNotifications.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UserNotifications

/// Creates local notifications for app events
struct LocalNotifications {
    // MARK: Properties
    
    let center = UNUserNotificationCenter.current()
    
    // MARK: Methods
    
    func enableNotification(on expirationDate: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Timer Done", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "The timer has finished running.", arguments: nil)
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: AudioCue.endCue.rawValue))
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: expirationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: K.notificationID, content: content, trigger: trigger)
        center.add(request)
    }
    
    func disableNotification() {
        center.removePendingNotificationRequests(withIdentifiers: [K.notificationID])
        center.removeDeliveredNotifications(withIdentifiers: [K.notificationID])
    }
}
