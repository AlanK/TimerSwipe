//
//  TimeAnnouncementController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 2/12/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeAnnouncementController {
    // MARK: Dependencies
    
    private var model = TimeAnnouncementPreference()
    
    // MARK: Properties
    
    private var scheduledAnnouncements = [Timer]()
    
    // MARK: Methods
    
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
    
    private func timeRemaining(_ seconds: TimeInterval) -> String {
        let smallNumberOfSeconds = Int(K.smallAmountOfTime)
        let wholeSeconds = Int(seconds)
        let wholeMinutes = wholeSeconds / 60
        let remainderSeconds = wholeSeconds % 60
        
        switch wholeSeconds {
        case 1..<smallNumberOfSeconds:
            return NSLocalizedString("abbreviatedTimeRemaining", value: "\(wholeSeconds)", comment: "A whole number of seconds (concisely)")
        case smallNumberOfSeconds..<60:
            return NSLocalizedString("timeRemaining", value: "\(wholeSeconds) seconds remaining", comment: "")
        case 60...:
            // I haven't made a string formatter to handle minutes + seconds, so this hack lives for now.
            let format = NSLocalizedString("number_of_minutes_remaining", comment: "")
            return remainderSeconds == 0 ? String.localizedStringWithFormat(format, wholeMinutes) : ""
        default: return ""
        }
    }
}
