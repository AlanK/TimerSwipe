//
//  TimeAnnouncementController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 2/12/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class TimeAnnouncementController: NSObject {
    private var model = TimeAnnouncementPreference()
    private var scheduledAnnouncements = [Timer]()
    
    func configureTimeAnnouncements(for expirationDate: Date, duration: TimeInterval) {
        var announcementTimes = [3.0, 2.0, 1.0]
        
        if duration >= 15.0 { announcementTimes.append(10.0) }
        if duration >= 45.0 { announcementTimes.append(30.0) }
        if duration >= 120.0 {
            var secondsIndex = 60.0
            
            while secondsIndex + 60.0 <= duration {
                announcementTimes.append(secondsIndex)
                secondsIndex += 60.0
            }
        }
        
        scheduledAnnouncements.append(contentsOf: announcementTimes.map { secondsRemaining -> Timer in
            let dateOfAnnouncement = expirationDate - secondsRemaining
            let timeInterval = dateOfAnnouncement.timeIntervalSince(Date())
            
            return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) {_ in
                guard self.model.preference == true else { return }
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.timeRemaining(secondsRemaining))
            }
        })
    }
    
    func cancelTimeAnnouncements() {
        _ = scheduledAnnouncements.map { $0.invalidate() }
        scheduledAnnouncements = [Timer]()
    }
    
    func togglePreference() {
        model.preference = !(model.preference)
    }

    func preferenceInstructions() -> String {
        switch model.preference {
        case true: return NSLocalizedString("turnOffAnnouncementPreference", value: "Turn off time remaining announcements", comment: "")
        case false: return NSLocalizedString("turnOnAnnouncementPreference", value: "Turn on time remaining announcements", comment: "")
        }
    }
    
    func timeRemaining(_ seconds: TimeInterval) -> String {
        let wholeSeconds = Int(seconds)
        let wholeMinutes = wholeSeconds/60
        let remainderSeconds = wholeSeconds%60
        
        if wholeMinutes > 0 && remainderSeconds == 0 {
            let format = NSLocalizedString("number_of_minutes_remaining", comment: "")
            return String.localizedStringWithFormat(format, wholeMinutes)
        } else if seconds > K.smallAmountOfTime {
            return NSLocalizedString("timeRemaining", value: "\(wholeSeconds) seconds remaining", comment: "")
        } else {
            return NSLocalizedString("abbreviatedTimeRemaining", value: "\(wholeSeconds)", comment: "The shortest way of expressing a whole number of seconds")
        }
    }
}
