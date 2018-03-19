//
//  ContainerViewAccessorizer.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct ContainerViewAccessorizer {
    func configure(_ view: UIView, owner: MainViewController) {
        let primaryAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.containerAlternateAction)) { [unowned owner] in
            return owner.strings.buttonLabel(timerIsReady: owner.countdown.ready)
        }
        
        let toggleAction = CustomAccessibilityAction(target: owner, selector: #selector(MainViewController.toggleAnnouncements)) { [unowned owner] in
            return owner.timeAnnouncementController.preferenceInstructions
        }
        
        view.isAccessibilityElement = true
        view.accessibilityTraits = UIAccessibilityTraitSummaryElement
        view.accessibilityCustomActions = [primaryAction, toggleAction]
        view.accessibilityLabel = owner.strings.containerViewLabel(timerReady: true, timerDuration: owner.duration)
    }
}
