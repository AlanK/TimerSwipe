//
//  TimeAnnouncementController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 2/12/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeAnnouncementController {
    private var model = TimeAnnouncementPreference()
    private var scheduledAnnouncements = [Timer]()
    
    mutating func configureTimeAnnouncements(for expirationDate: Date, duration: TimeInterval) {
        let model = self.model
        let timeRemaining = self.timeRemaining
        
        scheduledAnnouncements = (1..<Int(duration))
            .filter {
                switch $0 {
                case 1...3: return true
                case 10, 30: return duration >= TimeInterval(3 * $0 / 2)
                case 60...: return $0 + 60 <= Int(duration) && $0 % 60 == 0
                default: return false
                }
            }
            .map { TimeInterval($0) }
            .map { secondsRemaining -> Timer in
            let dateOfAnnouncement = expirationDate - secondsRemaining
            let timeInterval = dateOfAnnouncement.timeIntervalSince(Date())
            
            return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                guard model.preference == true else { return }
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, timeRemaining(secondsRemaining))
            }
        }
    }
    
    mutating func cancelTimeAnnouncements() {
        scheduledAnnouncements.forEach { $0.invalidate() }
        scheduledAnnouncements = [Timer]()
    }
    
    mutating func togglePreference() { model.preference = !(model.preference) }

    func preferenceInstructions() -> String {
        switch model.preference {
        case true: return NSLocalizedString("turnOffAnnouncementPreference", value: "Turn off time remaining announcements", comment: "")
        case false: return NSLocalizedString("turnOnAnnouncementPreference", value: "Turn on time remaining announcements", comment: "")
        }
    }
    
    func timeRemaining(_ seconds: TimeInterval) -> String {
        let wholeSeconds = Int(seconds)
        let wholeMinutes = wholeSeconds / 60
        let remainderSeconds = wholeSeconds % 60
        
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
