//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Primary view controller—displays the selected timer
class STViewController: UIViewController {
    /// Object that takes an integer in centiseconds and outputs a string for display
    private var timeFormatter = TimeFormatter()
    /// Plays the timer start and finish sounds
    let soundController = SoundController()
    /// Controls the text for the change/cancel button (and cancels a running timer)
    var buttonStatus = ChangeButtonValue.change
    /// The object that runs the selected timer
    private var stopwatch: Stopwatch?
    /// The duration of the selected timer
    var providedDuration: Int?
    
    // MARK: - Labels & Buttons
    
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel!
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel!
    /// The Change/Cancel button
    @IBOutlet var changeButton: UIButton!
    
    // MARK: - Actions
    
    // Trigger buttonActions() when tapping the Change/Cancel button
    @IBAction func changeButton(_ sender: AnyObject) {buttonActions()}
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
    
    // MARK: - View Loading and Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make the timer display huge with monospaced numbers
        timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: K.timerDisplaySize, weight: UIFontWeightRegular)
        // Use providedDuration, then the favorite timer, then the default timer
        if providedDuration == nil {
            let modelController = self.navigationController as? ModelController
            providedDuration = modelController?.model?.favorite()?.centiseconds ?? K.defaultDurationInCentiseconds
        }
        guard let providedDuration = providedDuration else {return}
        stopwatch = Stopwatch.init(delegate: self, duration: providedDuration)
        // Ready the stopwatch
        stopwatch?.clear()
        // Provide accessible instructions for this timer
        changeButton.accessibilityLabel = NSLocalizedString("timerReady", value: "\(providedDuration/100)-second timer, changes timer", comment: "{Whole number}-second timer (When activated, this button) changes timer")
        changeButton.accessibilityHint = NSLocalizedString("magicTap", value: "Two-finger double-tap starts or cancels timer.", comment: "Tapping twice with two fingers starts or cancels the timer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Turn off idle lock on this screen
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Turn on idle lock when leaving this screen
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Display Updating
    
    /// Updates the timer display with an integer in centiseconds
    func displayInt(_ integer: Int) {timeDisplay.text = timeFormatter.formatTime(integer)}
    
    // MARK: - Convenience
    
    /// Tells the Stopwatch to start the timer
    private func start() {stopwatch?.startTimer()}
    
    /// Handles taps on the Change/Cancel button
    func buttonActions() {
        switch buttonStatus {
        // If the change button is tapped, go back one level in the view hierarchy
        case .change: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case .cancel:
            setButton(to: .change)
        }
    }
    
    /// Sets the enum that controls the value of the Change/Cancel button and interrupts the running timer
    func setButton(to buttonValue: ChangeButtonValue) {
        buttonStatus = buttonValue
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.changeButton.setTitle(buttonStatus.text, for: UIControlState())
            self.changeButton.layoutIfNeeded()
        }
    }
}

// MARK: - STViewController Extensions

extension STViewController: StopwatchDelegate {
    /// Unlocks and locks the stopwatch to prevent multiple timers from running at once
    var unlocked: Bool {
        // Map unlock status to buttonStatus (.change = unlocked)
        switch buttonStatus {
        case .change: return true
        case .cancel: return false
        }
    }
    
    /// Updates the timer display with an integer in centiseconds
    func updateDisplay(with integer: Int) {
        displayInt(integer)
    }
    
    /// Handle changes in timer status
    func timerDid(_ status: TimerStatus) {
        switch status {
        case .start:
            soundController.playStartSound()
            // Make an accessibility announcement that the timer has started
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("startedTimer", value: "Started timer", comment: "The timer has started"))
            guard let providedDuration = providedDuration else {return}
            // Update the one accessible element on this screen with accessibility info describing the running timer and how to cancel it
            changeButton.accessibilityLabel = NSLocalizedString("runningTimer", value: "Running \(providedDuration/100)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
        case .end:
            soundController.playEndSound()
            // Make an accessibility announcement that the timer has ended
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"))
            guard let providedDuration = providedDuration else {return}
            // Update the one accessible element on this screen with accessibility info describing the available timer and how to change it
            changeButton.accessibilityLabel = NSLocalizedString("changesTimer", value: "\(providedDuration/100)-second timer, changes timer", comment: "{Whole number}-second timer (When activated, this button} changes the timer")
        case .cancel:
            // Make an accessibility announcement that the timer was cancelled
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("canceldTimer", value: "Cancelled timer", comment: "The timer has been cancelled"))
            guard let providedDuration = providedDuration else {return}
            // Update the one accessible element on this screen with accessibility info describing the available timer and how to change it
            changeButton.accessibilityLabel = NSLocalizedString("changesTimer", value: "\(providedDuration/100)-second timer, changes timer", comment: "{Whole number}-second timer (When activated, this button} changes the timer")
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
