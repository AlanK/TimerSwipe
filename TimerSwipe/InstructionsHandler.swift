//
//  InstructionsHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct InstructionsHandler {
    
    private let instructions: UILabel
    
    init(_ instructions: UILabel) {
        self.instructions = instructions
    }
    
    func animate(to isReady: Bool) {
        let instructions = self.instructions
        UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {
            instructions.alpha = isReady ? K.enabledAlpha : K.disabledAlpha
        })
    }
    
    func setText(voiceOverOn: Bool) { instructions.text = textInstructions(voiceOverIsOn: voiceOverOn) }
    
    /**
     Text for visible instructions depending on VoiceOver Status
     - parameter voiceOverOn: the status of VoiceOver
     - returns: instructions to display to the user
     */
    private func textInstructions(voiceOverIsOn: Bool) -> String {
        switch voiceOverIsOn {
        case true: return NSLocalizedString("Double-Tap to Start",
                                            comment: "Double-tap anywhere on the screen to start the timer")
        case false: return NSLocalizedString("Swipe to Start",
                                             comment: "Swipe anywhere on the screen in any direction to start the timer")
        }
    }
}
