//
//  SoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import AudioToolbox

class SoundController {
    var firstSound: SystemSoundID = 0
    var secondSound: SystemSoundID = 1
    
    init() {
        let firstSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "AudioCue_01" as CFString!, "aif" as CFString!, nil)
        AudioServicesCreateSystemSoundID(firstSoundURLRef!, &firstSound)
        
        let secondSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "AudioCue_02" as CFString!, "aif" as CFString!, nil)
        AudioServicesCreateSystemSoundID(secondSoundURLRef!, &secondSound)
    }
    
    func playFirstSound() {
        AudioServicesPlayAlertSound(firstSound)
    }
    
    func playSecondSound() {
        AudioServicesPlayAlertSound(secondSound)
    }
}
