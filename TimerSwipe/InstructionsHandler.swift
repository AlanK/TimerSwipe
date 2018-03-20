//
//  InstructionsHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct InstructionsHandler {
    // MARK: Dependencies
    
    private let instructions: UILabel
    
    // MARK: Initializers
    
    init(_ instructions: UILabel) {
        self.instructions = instructions
    }
    
    // MARK: Methods
    
    func animate(timerIs ready: Bool) {
        let instructions = self.instructions
        UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {
            instructions.alpha = ready ? K.enabledAlpha : K.disabledAlpha
        })
    }
    
    func setText(voiceOverOn: Bool) { instructions.text = textInstructions(voiceOverIsOn: voiceOverOn) }
    
    private func textInstructions(voiceOverIsOn: Bool) -> String {
        switch voiceOverIsOn {
        case true:
            return NSLocalizedString("Double-Tap to Start", comment: "Double-tap anywhere on the screen to start the timer")
        case false:
            return NSLocalizedString("Swipe to Start", comment: "Swipe anywhere on the screen in any direction to start the timer")
        }
    }
}
