//
//  SoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import AudioToolbox

struct SoundController {
    private var firstSound: SystemSoundID = 0
    private var secondSound: SystemSoundID = 1
    
    private let firstSoundName = "AudioCue_01" as CFString
    private let secondSoundName = "AudioCue_02" as CFString
    private let fileExtension = "aif" as CFString
    
    init() {
        if let firstSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), firstSoundName, fileExtension, nil) {
            AudioServicesCreateSystemSoundID(firstSoundURLRef, &firstSound)
        }
        if let secondSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), secondSoundName, fileExtension, nil) {
            AudioServicesCreateSystemSoundID(secondSoundURLRef, &secondSound)
        }
    }
    
    func playFirstSound() {
        AudioServicesPlayAlertSound(firstSound)
    }
    
    func playSecondSound() {
        AudioServicesPlayAlertSound(secondSound)
    }
}
