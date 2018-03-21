//
//  ContainerHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ContainerHandler {
    // MARK: Dependencies
    
    private let view: UIView
    private let recognizer: UITapGestureRecognizer
    
    // MARK: Initializers
    
    init(_ view: UIView, vc: MainViewController) {
        self.view = view
        recognizer = UITapGestureRecognizer(target: vc, action: #selector(MainViewController.containerViewActivated(sender:)))
    }
    
    // MARK: Methods
    
    func configure(owner: MainViewController, duration: TimeInterval) {
        let primaryAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.containerAlternateActivated)) { [unowned owner] in
            switch owner.countdownIsReady {
            case true:
                return NSLocalizedString("Change timer", comment: "Change the timer by selecting another one")
            case false:
                return NSLocalizedString("Cancel timer", comment: "Cancel the running timer")
            }
        }
        
        let toggleAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.toggleAnnouncements)) { [unowned owner] in
            return owner.timeAnnouncementPreferenceInstructions
        }
        
        view.isAccessibilityElement = true
        view.accessibilityTraits = UIAccessibilityTraitSummaryElement
        view.accessibilityCustomActions = [primaryAction, toggleAction]
        view.accessibilityLabel = label(timerIs: true, timerDuration: duration)
    }
    
    func voiceOver(voiceOverOn: Bool) {
        voiceOverOn ? view.addGestureRecognizer(recognizer) : view.removeGestureRecognizer(recognizer)
        view.layoutIfNeeded()
    }
    
    func label(timerIs ready: Bool, duration: TimeInterval) {
        view.accessibilityLabel = label(timerIs: ready, timerDuration: duration)
    }
    
    private func label(timerIs ready: Bool, timerDuration: TimeInterval) -> String {
        let textDuration = String(Int(timerDuration))
        switch ready {
        case true:
            return NSLocalizedString("timerReady",
                                     value: "\(textDuration)-second timer, starts timer",
                                     comment: "{Whole number}-second timer. (This button) starts the timer")
        case false:
            return NSLocalizedString("runningTimer",
                                     value: "Running \(textDuration)-second timer, cancels timer",
                                     comment: "Running {whole number}-second timer. (This button) cancels the timer")
        }
    }
}
