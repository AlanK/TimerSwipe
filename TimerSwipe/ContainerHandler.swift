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
    private unowned let vc: MainViewController
    
    // MARK: Initializers
    
    init(_ view: UIView, vc: MainViewController) {
        self.view = view
        recognizer = UITapGestureRecognizer(target: vc, action: #selector(MainViewController.containerViewActivated(sender:)))
        self.vc = vc
    }
    
    // MARK: Methods
    
    func configure(with duration: TimeInterval) {
        let primaryAction = CustomAccessibilityAction(target: vc, selector: #selector(MainViewController.containerAlternateActivated)) { [unowned vc] in
            switch vc.countdownIsReady {
            case true:
                return NSLocalizedString("Change timer", comment: "Change the timer by selecting another one")
            case false:
                return NSLocalizedString("Cancel timer", comment: "Cancel the running timer")
            }
        }
        
        let toggleAction = CustomAccessibilityAction(target: vc, selector: #selector(MainViewController.toggleAnnouncements)) { [unowned vc] in
            return vc.timeAnnouncementPreferenceInstructions
        }
        
        view.isAccessibilityElement = true
        view.accessibilityTraits = UIAccessibilityTraits.summaryElement
        view.accessibilityCustomActions = [primaryAction, toggleAction]
        view.accessibilityLabel = labelText(timerIs: true, duration: duration)
    }
    
    func voiceOver(voiceOverOn: Bool) {
        voiceOverOn ? view.addGestureRecognizer(recognizer) : view.removeGestureRecognizer(recognizer)
        view.layoutIfNeeded()
    }
    
    func label(timerIs ready: Bool, duration: TimeInterval) {
        view.accessibilityLabel = labelText(timerIs: ready, duration: duration)
    }
    
    private func labelText(timerIs ready: Bool, duration: TimeInterval) -> String {
        let textDuration = String(Int(duration))
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
