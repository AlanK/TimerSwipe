//
//  ButtonHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ButtonHandler {
    // MARK: Dependencies
    
    private let button: UIButton
    
    // MARK: Initializers
    
    init(_ button: UIButton) {
        self.button = button
    }
    
    // MARK: Methods
    
    func setTitle(timerIs ready: Bool) {
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            button.setTitle(buttonText(timerIs: ready), for: UIControlState())
            button.layoutIfNeeded()
        }
    }
    
    private func buttonText(timerIs ready: Bool) -> String {
        switch ready {
        case true:
            return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        case false:
            return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        }
    }
}
