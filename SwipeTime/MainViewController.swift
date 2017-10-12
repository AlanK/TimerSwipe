//
//  MainViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Primary view controller—displays the selected timer
class MainViewController: UIViewController {
    /// Controls the value of the Change/Cancel button
    private enum ButtonValue {
        case cancel
        case change
        // rawValue can't return an NSLocalizedString
        /// Returns a localized string with text for the Change/Cancel button
        var text: String {
            switch self {
            case .cancel: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
            case .change: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
            }
        }
    }
    /// The duration of the selected timer in seconds
    var duration: TimeInterval?
    /// Formats time as a string for display
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()
    /// Plays the timer start and finish sounds
    private let soundController = SoundController()
    /// Controls the text for the change/cancel button (and cancels a running timer)
    private var buttonStatus = ButtonValue.change
    /// The object that runs the selected timer
    private var stopwatch: Stopwatch?
    
    // MARK: Labels & Buttons
    
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel!
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel!
    /// The Change/Cancel button
    @IBOutlet var button: UIButton!
    
    // MARK: Actions
    
    // Trigger buttonActions() when tapping the Change/Cancel button
    @IBAction func button(_ sender: AnyObject) {buttonActions()}
    // Map the two-finger z-shaped "escape" accessibility command to the Change/Cancel button
    override func accessibilityPerformEscape() -> Bool {
        buttonActions()
        return true
    }
    
    // A swipe in any direction on the window fires start()
    @IBAction func swipeRight(_ sender: AnyObject) {start()}
    @IBAction func swipeLeft(_ sender: AnyObject) {start()}
    @IBAction func swipeUp(_ sender: AnyObject) {start()}
    @IBAction func swipeDown(_ sender: AnyObject) {start()}
    // A two-finger double-tap "magic tap" accessibility command starts/cancels the timer
    override func accessibilityPerformMagicTap() -> Bool {
        switch buttonStatus {
        case .change:
            start()
        case .cancel:
            buttonActions()
        }
        return true
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make the timer display huge with monospaced numbers
        timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: K.timerDisplaySize, weight: UIFont.Weight.regular)
        // Use providedDuration, then the favorite timer, then the default timer
        if duration == nil {
            let modelController = self.navigationController as? ModelController
            duration = modelController?.model.favorite()?.seconds ?? K.defaultDuration
        }
        
        guard let duration = duration else {return}
        stopwatch = Stopwatch.init(delegate: self, duration: duration)
        // Ensure the stopwatch and delegate are ready; set the display to the current timer
        stopwatch?.clear()
        // Provide accessible instructions for this timer
        button.accessibilityLabel = NSLocalizedString("timerReady",value: "\(Int(duration))-second timer, changes timer",comment: "{Whole number}-second timer (When activated, this button) changes timer")
        button.accessibilityHint = NSLocalizedString("magicTap", value: "Two-finger double-tap starts or cancels timer.", comment: "Tapping twice with two fingers starts or cancels the timer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Turn off idle lock for this view
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        soundController.setActive(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Turn on idle lock when leaving this view
        UIApplication.shared.isIdleTimerDisabled = false
        soundController.setActive(false)
    }
    
    // MARK: Display updating
    
    /// Updates the timer display with a time interval
    private func display(seconds: TimeInterval) {
        timeDisplay.text = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
    
    /// Hides the "Swipe to Start" instructions when a timer is running
    private func hideInstructions() {
        UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {self.instructionsDisplay.alpha = K.disabledAlpha}, completion: nil)
    }
    
    /// Shows the "Swipe to Start" instructions when a timer is not running
    private func showInstructions() {
        UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {self.instructionsDisplay.alpha = K.enabledAlpha}, completion: nil)
    }
    
    // MARK: Convenience
    
    func killTimer() {
        soundController.warn()
        buttonActions()
    }
    
    /// Tells the Stopwatch to start the timer
    private func start() {stopwatch?.startTimer()}
    
    /// Handles taps on the Change/Cancel button
    private func buttonActions() {
        switch buttonStatus {
        // If the change button is tapped, go back one level in the view hierarchy
        case .change: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case .cancel:
            setButton(to: .change)
        }
    }
    
    /// Sets the enum that controls the value of the Change/Cancel button and interrupts the running timer
    private func setButton(to buttonValue: ButtonValue) {
        buttonStatus = buttonValue
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.button.setTitle(buttonStatus.text, for: UIControlState())
            self.button.layoutIfNeeded()
        }
    }
}

// MARK: - Stopwatch delegate

extension MainViewController: StopwatchDelegate {
    ///Reports lock status to the stopwatch to prevent multiple timers from running at once
    var unlocked: Bool {
        // Map unlock status to buttonStatus (.change = unlocked)
        switch buttonStatus {
        case .change: return true
        case .cancel: return false
        }
    }
    
    /**
     Updates the timer display with a time interval.
     
     - parameters:
     - seconds: time remaining in `TimeInterval`
     */
    func updateDisplay(with seconds: TimeInterval) {
        display(seconds: seconds)
    }
    
    /// Handle changes in timer status
    func timerDid(_ status: TimerStatus) {
        let defaultDisplay: String = "00:00.00"
        /// String of the timer duration (or "Unknown" if duration is unavailable)
        var textDuration: String {
            guard let duration = duration else {return defaultDisplay}
            return String(Int(duration))
        }
        
        /// Reset the Change Button accessibility label and instructions
        func resetView() {
            button.accessibilityLabel = NSLocalizedString("changesTimer", value: "\(textDuration)-second timer, changes timer", comment: "{Whole number}-second timer (When activated, this button) changes the timer")
            showInstructions()
        }
        
        switch status {
        case .start:
            soundController.playStartSound()
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("startedTimer", value: "Started timer", comment: "The timer has started"))
            button.accessibilityLabel = NSLocalizedString("runningTimer", value: "Running \(textDuration)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
            hideInstructions()
        case .end:
            soundController.playEndSound()
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"))
            resetView()
        case .cancel:
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("canceldTimer", value: "Cancelled timer", comment: "The timer has been cancelled"))
            resetView()
        }
    }
    
    /// Locks the stopwatch to prevent multiple timers from running simultaneously
    func lock() {
        // Set the Change/Cancel button to cancel
        setButton(to: .cancel)
    }
    
    /// Unlocks the stopwatch when no timer is running
    func unlock() {
        // Set the Change/Cancel button to change
        setButton(to: .change)
    }
}
