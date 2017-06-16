//
//  SoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import AudioToolbox

/// Handles sounds for the main view of the app
struct SoundController {
    // Create two system sound IDs
    private var firstSound: SystemSoundID = 0, secondSound: SystemSoundID = 1
    // Create the CFStrings for getting the sound files
    private let firstSoundName = "AudioCue_01" as CFString, secondSoundName = "AudioCue_02" as CFString, fileExtension = "aif" as CFString
    
    /// Create two system sound objects
    init() {
        if let firstSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), firstSoundName, fileExtension, nil) {
            AudioServicesCreateSystemSoundID(firstSoundURLRef, &firstSound)
        }
        if let secondSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), secondSoundName, fileExtension, nil) {
            AudioServicesCreateSystemSoundID(secondSoundURLRef, &secondSound)
        }
    }
    
    /// Plays the "timer start" sound
    func playStartSound() {
        AudioServicesPlayAlertSound(firstSound)
    }
    
    /// Plays the "timer end" sound
    func playEndSound() {
        AudioServicesPlayAlertSound(secondSound)
    }
}
