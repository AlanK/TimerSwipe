//
//  ContainerViewAccessorizer.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ContainerViewAccessorizer {
    
    private let recognizer: UITapGestureRecognizer
    
    init(_ vc: MainViewController) {
        recognizer = UITapGestureRecognizer(target: vc, action: #selector(MainViewController.containerViewActivated(sender:)))
    }
    
    func configure(_ view: UIView, owner: MainViewController, duration: TimeInterval) {
        let primaryAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.containerAlternateActivated)) { [unowned owner] in
            return owner.strings.buttonLabel(timerIsReady: owner.countdown.ready)
        }
        
        let toggleAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.toggleAnnouncements)) { [unowned owner] in
            return owner.timeAnnouncementController.preferenceInstructions
        }
        
        
        
        view.isAccessibilityElement = true
        view.accessibilityTraits = UIAccessibilityTraitSummaryElement
        view.accessibilityCustomActions = [primaryAction, toggleAction]
        view.accessibilityLabel = label(timerReady: true, timerDuration: duration)
    }
    
    func voiceOver(_ view: UIView, voiceOverOn: Bool) {
        voiceOverOn ? view.addGestureRecognizer(recognizer) : view.removeGestureRecognizer(recognizer)
        view.layoutIfNeeded()
    }
    
    func label(_ view: UIView, timerReady: Bool, duration: TimeInterval) {
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
