//
//  MainViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Enables other parts of the app to check for and kill running timers
protocol StopwatchIntermediary {
    /// Reports whether a timer is active
    var timerNotRunning: Bool {get}
    /// Causes any active timer to die with an audible warning to the user
    func killTimer()
}

/// Primary view controller—displays the selected timer
class MainViewController: UIViewController {
    static private let timerStarted = NSLocalizedString("timerStarted", value: "Started timer, double-tap to cancel", comment: "The timer has started, double-tap anywhere on the screen to cancel the running timer"),
    timerEnded = NSLocalizedString("timerFinished", value: "Timer finished", comment: "The timer has finished"),
    timerCancelled = NSLocalizedString("timerCancelled", value: "Cancelled timer", comment: "The timer has been cancelled")
    
    /// Controls the value of the Change/Cancel button
    private enum ButtonValue {
        case cancel
        case change
        // rawValue can't return an `NSLocalizedString`
        /// Returns a localized string with text for the Change/Cancel button
        var text: String {
            switch self {
            case .cancel: return NSLocalizedString("cancelButton", value: "Cancel", comment: "Cancel the timer that is currently running")
            case .change: return NSLocalizedString("changeButton", value: "Change", comment: "Change which timer is displayed")
            }
        }
        var accessibleLabel: String {
            switch self {
            case .cancel: return NSLocalizedString("cancelTimer", value: "Cancel timer", comment: "Cancel the running timer")
            case .change: return NSLocalizedString("changeTimer", value: "Change timer", comment: "Change the timer by selecting another one")
            }
        }
    }
    
    private enum Instructions {
        case normal
        case voiceOver
        var text: String {
            switch self {
            case .normal: return NSLocalizedString("swipeToStart", value: "Swipe to Start", comment: "Swipe anywhere on the screen in any direction to start the timer")
            case .voiceOver: return NSLocalizedString("doubleTapToStart", value: "Double-Tap to Start", comment: "Double-tap anywhere on the screen to start the timer")
            }
        }
    }
    
    private var defaultContainerViewLabel: String {
        return NSLocalizedString("timerReady", value: "\(textDuration)-second timer, starts timer", comment: "{Whole number}-second timer (When activated, this button) starts the timer")
    }
    
    private var runningTimerContainerViewLabel: String {
        return NSLocalizedString("runningTimer", value: "Running \(textDuration)-second timer, cancels timer", comment: "Running {whole number}-second timer (When activated, this button) cancels the timer")
    }
    
    private var textDuration: String {
        return String(Int(duration))
    }
    
    private let notificationCenter = NotificationCenter.default

    /// Formats time as a string for display
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        return formatter
    }()

    private let soundController = SoundController()
    
    // Use duration provided from elsewhere, then the favorite timer, then the default timer
    var providedDuration: TimeInterval?
    private lazy var duration = providedDuration ?? (self.navigationController as? ModelIntermediary)?.model.favorite()?.seconds ?? K.defaultDuration
    
    private var buttonStatus = ButtonValue.change
    
    private lazy var stopwatch: Stopwatch = Stopwatch.init(delegate: self, duration: duration)

    
    /// Shows and hides "Swipe to Start" instructions
    private var instructionsVisible = true {
        didSet {
            let alpha = instructionsVisible ? K.enabledAlpha : K.disabledAlpha
            UIView.animate(withDuration: K.instructionsAnimationDuration, delay: 0, options: .curveLinear, animations: {self.instructionsDisplay.alpha = alpha})
        }
    }
    
    private lazy var tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(containerViewAsButton(sender:)))
    
    private lazy var containerViewAction = UIAccessibilityCustomAction.init(name: buttonStatus.accessibleLabel, target: self, selector: #selector(buttonActions))

    
    // MARK: Labels & Buttons
    
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel! {
        didSet {
            instructionsDisplay.text = Instructions.normal.text
        }
    }
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel! {
        didSet {
            timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: K.timerDisplaySize, weight: UIFont.Weight.regular)
        }
    }
    /// The Change/Cancel button
    @IBOutlet var button: UIButton!
    @IBOutlet var containerView: UIStackView! {
        didSet {
            containerView.isAccessibilityElement = true
            containerView.accessibilityTraits = UIAccessibilityTraitSummaryElement
            containerView.accessibilityCustomActions = [containerViewAction]
            containerView.accessibilityLabel = defaultContainerViewLabel
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
        switch buttonStatus {
        case .change: start()
        case .cancel: buttonActions()
        }
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
        switch buttonStatus {
        // If the change button is tapped, go back one level in the view hierarchy
        case .change: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case .cancel: setButton(to: .change)
        }
    }
    
    /**
     Sets the `enum` that controls the value of the Change/Cancel button and interrupts the running timer
     - parameter buttonValue: the value to which the button should be set
     */
    private func setButton(to buttonValue: ButtonValue) {
        buttonStatus = buttonValue
        containerViewAction.name = buttonStatus.accessibleLabel
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.button.setTitle(buttonStatus.text, for: UIControlState())
            self.button.layoutIfNeeded()
        }
    }
    
    private func customizeDisplayForVoiceOver(_: Notification? = nil) {
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        instructionsDisplay.text = voiceOverOn ? Instructions.voiceOver.text : Instructions.normal.text
        containerView.layoutIfNeeded()
        
        switch voiceOverOn {
        case true: containerView.addGestureRecognizer(tapRecognizer)
        case false: containerView.removeGestureRecognizer(tapRecognizer)
        }
    }
    
    private func registerNotifications(_ register: Bool) {
        switch register {
        case true:
            if #available(iOS 11.0, *) {
                notificationCenter.addObserver(forName: .UIAccessibilityVoiceOverStatusDidChange, object: nil, queue: nil, using: customizeDisplayForVoiceOver(_:))
            }
        case false:
            if #available(iOS 11.0, *) {
                notificationCenter.removeObserver(self, name: .UIAccessibilityVoiceOverStatusDidChange, object: nil)
            }
        }
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the stopwatch and delegate are ready; set the display to the current timer
        stopwatch.clear()
        // Customize display based on VoiceOver settings
        customizeDisplayForVoiceOver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications(true)
        // The display shouldn’t sleep while this view is visible since the user expects to start a timer when they can’t see the screen
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        soundController.setActive(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        registerNotifications(false)
        // The display should sleep in other views in the app
        UIApplication.shared.isIdleTimerDisabled = false
        soundController.setActive(false)
    }
    
    // MARK: Display updating
    
    /// Updates the timer display with a time interval
    private func display(seconds: TimeInterval) {
        timeDisplay.text = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: seconds))
    }
}

// MARK: - Stopwatch delegate

extension MainViewController: StopwatchDelegate {
    var timerNotRunning: Bool {return (buttonStatus == .change)}
    
    /**
     Updates the timer display with a time interval.
     - parameter seconds: time remaining as a `TimeInterval`
     */
    func updateDisplay(with seconds: TimeInterval) {
        display(seconds: seconds)
    }
    
    /**
     Handle changes in timer status
     - parameter status: whether the timer started, ended, or was cancelled
    */
    func timerDid(_ status: TimerStatus) {
        func cleanupActions() {
            containerView.accessibilityLabel = defaultContainerViewLabel
            instructionsVisible = true
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
        
        switch status {
        case .start:
            soundController.play(.start)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, MainViewController.timerStarted)
            containerView.accessibilityLabel = runningTimerContainerViewLabel
            instructionsVisible = false
        case .end:
            soundController.play(.end)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, MainViewController.timerEnded)
            cleanupActions()
        case .cancel:
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, MainViewController.timerCancelled)
            cleanupActions()
        }
    }
    
    /// Locks the stopwatch to prevent multiple timers from running simultaneously
    func lock() {setButton(to: .cancel)}
    
    /// Unlocks the stopwatch when no timer is running
    func unlock() {setButton(to: .change)}
}

// MARK: - StopwatchIntermediary

extension MainViewController: StopwatchIntermediary {
    func killTimer() {
        if buttonStatus == .cancel {buttonActions()}
        soundController.play(.die)
    }
}
