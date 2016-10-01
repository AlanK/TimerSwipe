//
//  STSoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit
import AudioToolbox

class STSoundController: NSObject {

    let firstSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "AudioCue_01" as CFString!, "aif" as CFString!, nil)
    var firstSoundID: SystemSoundID = 0
    
    let secondSoundURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "AudioCue_02" as CFString!, "aif" as CFString!, nil)
    var secondSoundID: SystemSoundID = 1
    
    func playFirstSound() {
        AudioServicesCreateSystemSoundID(firstSoundURLRef!, &firstSoundID)
        AudioServicesPlayAlertSound(firstSoundID)
    }
    
    func playSecondSound() {
        AudioServicesCreateSystemSoundID(secondSoundURLRef!, &secondSoundID)
        AudioServicesPlayAlertSound(secondSoundID)
    }
    
}
