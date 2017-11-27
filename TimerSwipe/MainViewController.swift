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
    // MARK: Class Properties
    // Localized strings for StopwatchDelegate events
    private static let timerStarted = NSLocalizedString("timerStarted", value: "Started timer, double-tap to cancel", comment: "The timer has started, double-tap anywhere on the screen to cancel the running timer"),
    timerEnded = NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"),
    timerCancelled = NSLocalizedString("timerCancelled", value: "Cancelled timer", comment: "The timer has been cancelled")
    /// Returns a localized string with text for the Change/Cancel button
    private static func buttonText(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
        case false: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
        }
    }
    /// Returns a localized string with VoiceOver instructions for the Change/Cancel button
    private static func buttonLabel(timerIsReady: Bool) -> String {
        switch timerIsReady {
        case true: return NSLocalizedString("changeTimer", value: "Change timer", comment: "Change the timer by selecting another one")
        case false: return NSLocalizedString("cancelTimer", value: "Cancel timer", comment: "Cancel the running timer")
        }
    }

    /**
     Text for visible instructions depending on VoiceOver Status
     - parameter voiceOverOn: the status of VoiceOver
     - returns: instructions to display to the user
     */
    private static func textInstructions(voiceOverIsOn: Bool) -> String {
        switch voiceOverIsOn {
        case true:
            return NSLocalizedString("doubleTapToStart", value: "Double-Tap to Start", comment: "Double-tap anywhere on the screen to start the timer")
        case false:
            return NSLocalizedString("swipeToStart", value: "Swipe to Start", comment: "Swipe anywhere on the screen in any direction to start the timer")
        }
    }

    /**
     Spoken instructions based on timer status and duration
     - parameter timerReady: the status of the timer
     - parameter timerDuration: the duration of the timer
     - returns: VoiceOver instructions for the user
     */
    private static func containerViewLabel(timerReady: Bool, timerDuration: TimeInterval) -> String {
        let textDuration = String(Int(timerDuration))
        switch timerReady {
        case true:
            return NSLocalizedString("timerReady", value: "\(textDuration)-second timer, starts timer", comment: "{Whole number}-second timer (When activated, this button) starts the timer")
        case false:
            return NSLocalizedString("runningTimer", value: "Running \(textDuration)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
        }
    }
    /// Font settings for the timer display
    private static let timeFont = UIFont.monospacedDigitSystemFont(ofSize: 64.0, weight: UIFont.Weight.regular)
    
    // MARK: - Instance
    
    private let timeFormatter = TimeFormatter()
    private let soundController = SoundController()
    
    // MARK: Duration Properties
    // Use duration provided from elsewhere, then the favorite timer, then the default timer
    var providedDuration: TimeInterval?
    private lazy var duration = providedDuration ?? (self.navigationController as? ModelIntermediary)?.model.favorite()?.seconds ?? K.defaultDuration

    // MARK: Stopwatch Properties
    private lazy var stopwatch: Stopwatch = Stopwatch.init(delegate: self, duration: duration)
    var timerReady: Bool = true {
        didSet {
            containerViewAction.name = MainViewController.buttonLabel(timerIsReady: timerReady)
            // Use performWithoutAnimation to prevent weird flashing as button text animates.
            UIView.performWithoutAnimation {
                self.button.setTitle(MainViewController.buttonText(timerIsReady: timerReady), for: UIControlState())
                self.button.layoutIfNeeded()
            }
        }
    }
    
    /// Shows and hides "Swipe to Start" instructions
    private var instructionsVisible = true {
        didSet {
            let alpha = instructionsVisible ? K.enabledAlpha : K.disabledAlpha
            UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {
                self.instructionsDisplay.alpha = alpha
            })
        }
    }
    
    private lazy var tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(containerViewAsButton(sender:)))
    
    private lazy var containerViewAction = UIAccessibilityCustomAction.init(name: MainViewController.buttonLabel(timerIsReady: timerReady), target: self, selector: #selector(buttonActions))

    
    // MARK: Labels & Buttons
    
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel! {
        didSet {
            instructionsDisplay.text = MainViewController.textInstructions(voiceOverIsOn: false)
        }
    }
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel! {
        didSet {
            timeDisplay.font = MainViewController.timeFont
        }
    }
    /// The Change/Cancel button
    @IBOutlet var button: UIButton!
    @IBOutlet var containerView: UIStackView! {
        didSet {
            containerView.isAccessibilityElement = true
            containerView.accessibilityTraits = UIAccessibilityTraitSummaryElement
            containerView.accessibilityCustomActions = [containerViewAction]
            containerView.accessibilityLabel = MainViewController.containerViewLabel(timerReady: true, timerDuration: duration)
        }
    }
    
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
        timerReady ? start() : buttonActions()
        return true
    }
    
    @objc func containerViewAsButton(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {return}
        _ = accessibilityPerformMagicTap()
    }
    
    /// Tells the Stopwatch to start the timer
    private func start() {stopwatch.startTimer()}
    
    /// Handles taps on the Change/Cancel button
    @objc private func buttonActions() {
        switch timerReady {
        // If the change button is tapped, go back one level in the view hierarchy
        case true: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case false: timerReady = true
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the stopwatch and delegate are ready; set the display to the current timer
        stopwatch.clear()
        // Customize display based on VoiceOver settings
        voiceOverStatusDidChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The display shouldn’t sleep while this view is visible since the user expects to start a timer when they can’t see the screen
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        soundController.setActive(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The display should sleep in other views in the app
        UIApplication.shared.isIdleTimerDisabled = false
        soundController.setActive(false)
    }
}

// MARK: - Stopwatch delegate

extension MainViewController: StopwatchDelegate {
    /**
     Updates the timer display with a time interval.
     - parameter seconds: time remaining as a `TimeInterval`
     */
    func updateDisplay(with seconds: TimeInterval) {
        timeDisplay.text = timeFormatter.display(time: seconds)
    }
    
    /**
     Handle changes in timer status
     - parameter status: whether the timer started, ended, or was cancelled
    */
    func timerDid(_ status: TimerStatus) {
        func notifyUserOfTimerStatus(notice: String, sound: AudioCue? = nil) {
            if let sound = sound {
                soundController.play(sound)
            }
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice)
            containerView.accessibilityLabel = MainViewController.containerViewLabel(timerReady: (status != .start), timerDuration: duration)
            instructionsVisible = (status != .start)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
        
        switch status {
        case .start: notifyUserOfTimerStatus(notice: MainViewController.timerStarted, sound: .startCue)
        case .end: notifyUserOfTimerStatus(notice: MainViewController.timerEnded, sound: .endCue)
        case .cancel: notifyUserOfTimerStatus(notice: MainViewController.timerCancelled)
        }
    }
    
    /// Locks the stopwatch to prevent multiple timers from running simultaneously
    func lock() {timerReady = false}
    
    /// Unlocks the stopwatch when no timer is running
    func unlock() {timerReady = true}

    // This view controller can kill a running timer directly
    func killTimer() {
        if timerReady == false {
            buttonActions()
            soundController.play(.dieCue)
        }
    }
}

// MARK: - VoiceOverObserver
// Receive notifications when VoiceOver status changes
extension MainViewController: VoiceOverObserver {
    /// Change the text instructions to match the VO-enabled interaction paradigm and make the containerView touch-enabled
    func voiceOverStatusDidChange(_: Notification? = nil) {
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        instructionsDisplay.text = MainViewController.textInstructions(voiceOverIsOn: voiceOverOn)
        voiceOverOn ? containerView.addGestureRecognizer(tapRecognizer) : containerView.removeGestureRecognizer(tapRecognizer)
        containerView.layoutIfNeeded()
    }
}
