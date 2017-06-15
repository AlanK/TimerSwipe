//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STViewController: UIViewController {
    
    var timeFormatter = TimeFormatter()
    let soundController = SoundController()
    
    var buttonStatus = ChangeButtonValue.change
    
    var stopwatch: Stopwatch?
    var providedDuration: Int?
    
    // MARK: - Labels & Buttons
    
    @IBOutlet var instructionsDisplay: UILabel!
    @IBOutlet var timeDisplay: UILabel!
    @IBOutlet var changeButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func changeButton(_ sender: AnyObject) {buttonActions()}
    override func accessibilityPerformEscape() -> Bool {
        buttonActions()
        return true
    }
    
    @IBAction func swipeRight(_ sender: AnyObject) {start()}
    @IBAction func swipeLeft(_ sender: AnyObject) {start()}
    @IBAction func swipeUp(_ sender: AnyObject) {start()}
    @IBAction func swipeDown(_ sender: AnyObject) {start()}
    override func accessibilityPerformMagicTap() -> Bool {
        switch buttonStatus {
        case .change:
            start()
        case .cancel:
            buttonActions()
        }
        return true
    }
    
    // MARK: - View Loading and Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: 64, weight: UIFontWeightRegular)
        if providedDuration == nil {
            let modelController = self.navigationController as? ModelController
            providedDuration = modelController?.model?.favorite()?.centiseconds ?? K.defaultDurationInCentiseconds
        }
        guard let providedDuration = providedDuration else {return}
        stopwatch = Stopwatch.init(delegate: self, duration: providedDuration)
        stopwatch?.clearTimer()
        changeButton.accessibilityLabel = "\(providedDuration/100)-second timer, changes timer"
        changeButton.accessibilityHint = "Two-finger double-tap starts or cancels timer."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Display Updating
    
    func displayInt(_ integer: Int) {timeDisplay.text = timeFormatter.formatTime(integer)}
    
    // MARK: - Convenience
    
    func start() {stopwatch?.startTimer()}
    
    func buttonActions() {
        switch buttonStatus {
        case .change: self.navigationController?.popViewController(animated: true)
        case .cancel: stopwatch?.cancel()
        }
    }
}

// MARK: - STViewController Extensions

extension STViewController: StopwatchDelegate {
    func updateDisplay(with integer: Int) {
        displayInt(integer)
    }
    
    func setButton(to buttonValue: ChangeButtonValue) {
        buttonStatus = buttonValue
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.changeButton.setTitle(buttonStatus.rawValue, for: UIControlState())
            self.changeButton.layoutIfNeeded()
        }
    }
    
    func timerDidStart() {
        soundController.playFirstSound()
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Started timer")
        guard let providedDuration = providedDuration else {return}
        changeButton.accessibilityLabel = "Running \(providedDuration/100)-second timer, cancels timer"
    }
    
    func timerDidEnd() {
        soundController.playSecondSound()
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Timer finished")
        guard let providedDuration = providedDuration else {return}
        changeButton.accessibilityLabel = "\(providedDuration/100)-second timer, changes timer"
    }
    
    func timerDidCancel() {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Cancelled timer")
        guard let providedDuration = providedDuration else {return}
        changeButton.accessibilityLabel = "\(providedDuration/100)-second timer, changes timer"
    }
}
