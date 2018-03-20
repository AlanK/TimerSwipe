//
//  ContainerHandler.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ContainerHandler {
    
    private let view: UIView
    private let recognizer: UITapGestureRecognizer
    
    init(_ view: UIView, vc: MainViewController) {
        self.view = view
        recognizer = UITapGestureRecognizer(target: vc, action: #selector(MainViewController.containerViewActivated(sender:)))
    }
    
    func configure(owner: MainViewController, duration: TimeInterval) {
        let primaryAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.containerAlternateActivated)) { [unowned owner] in
            switch owner.countdown.ready {
            case true: return NSLocalizedString("Change timer",
                                                comment: "Change the timer by selecting another one")
            case false: return NSLocalizedString("Cancel timer",
                                                 comment: "Cancel the running timer")
            }
        }
        
        let toggleAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.toggleAnnouncements)) { [unowned owner] in
            return owner.timeAnnouncementController.preferenceInstructions
        }
        
        view.isAccessibilityElement = true
        view.accessibilityTraits = UIAccessibilityTraitSummaryElement
        view.accessibilityCustomActions = [primaryAction, toggleAction]
        view.accessibilityLabel = label(timerReady: true, timerDuration: duration)
    }
    
    func voiceOver(voiceOverOn: Bool) {
        voiceOverOn ? view.addGestureRecognizer(recognizer) : view.removeGestureRecognizer(recognizer)
        view.layoutIfNeeded()
    }
    
    func label(timerReady: Bool, duration: TimeInterval) {
        view.accessibilityLabel = label(timerReady: timerReady, timerDuration: duration)
    }
    
    /**
     Spoken instructions based on timer status and duration
     - parameter timerReady: the status of the timer
     - parameter timerDuration: the duration of the timer
     - returns: VoiceOver instructions for the user
     */
    private func label(timerReady: Bool, timerDuration: TimeInterval) -> String {
        let textDuration = String(Int(timerDuration))
        switch timerReady {
        case true: return NSLocalizedString("timerReady",
                                            value: "\(textDuration)-second timer, starts timer",
            comment: "{Whole number}-second timer. (This button) starts the timer")
        case false: return NSLocalizedString("runningTimer",
                                             value: "Running \(textDuration)-second timer, cancels timer",
            comment: "Running {whole number}-second timer. (This button) cancels the timer")
        }
    }
}
