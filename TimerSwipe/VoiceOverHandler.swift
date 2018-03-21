//
//  VoiceOverHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/18/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

/// This protocol should be adopted by any object that wants to respond to changes in VoiceOver status
protocol VoiceOverObserver: AnyObject {
    /// This function is called whenever VoiceOver status changes and is passed the relevant notification
    func voiceOverStatusDidChange(_: Notification?)
}

/// Registers for VoiceOver status notifications and passes them to a single computed observer
struct VoiceOverHandler {
    // MARK: Dependencies
    
    private let nc: NotificationCenter
    private unowned var observer: VoiceOverObserver
    
    // MARK: Initializers

    init(observer: VoiceOverObserver, nc: NotificationCenter? = nil) {
        self.nc = nc ?? NotificationCenter.default
        self.observer = observer
    }
    
    // MARK: Properties
    
    private var observation: NSObjectProtocol?
    
    // MARK: Methods
    
    /// Register and unregister for notifications on behalf of other VCs
    mutating func registerNotifications(_ register: Bool) {
        // UIAccessibilityVoiceOverStatusChanged and NSNotification.Name.UIAccessibilityVoiceOverStatusDidChange are the same notification in iOS 10 and iOS 11
        let voiceOverNotice: NSNotification.Name
        if #available(iOS 11.0, *) { voiceOverNotice = .UIAccessibilityVoiceOverStatusDidChange }
        else { voiceOverNotice = NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged) }
        
        switch register {
        case true:
            observation = nc.addObserver(forName: voiceOverNotice, object: nil, queue: nil, using: voiceOverStatusDidChange(_:))
            voiceOverStatusDidChange()
        case false:
            guard let voiceOverObservation = observation else { return }
            nc.removeObserver(voiceOverObservation, name: voiceOverNotice, object: nil)
        }
    }
    
    private func voiceOverStatusDidChange(_ notification: Notification? = nil) {
        observer.voiceOverStatusDidChange(notification)
    }
}
