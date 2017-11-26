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
    static let timeSize: CGFloat = 64.0
    static let timeWeight: UIFont.Weight = .regular
    

    
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
    
    private let displayStack = DisplayStack()
    
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
            instructionsDisplay.text = DisplayStack.textInstructions(voiceOverOn: false)
        }
    }
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel! {
        didSet {
            timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: MainViewController.timeSize, weight: MainViewController.timeWeight)
        }
    }
    /// The Change/Cancel button
    @IBOutlet var button: UIButton!
    @IBOutlet var containerView: UIStackView! {
        didSet {
            containerView.isAccessibilityElement = true
            containerView.accessibilityTraits = UIAccessibilityTraitSummaryElement
            containerView.accessibilityCustomActions = [containerViewAction]
            containerView.accessibilityLabel = DisplayStack.containerViewLabel(timerReady: true, timerDuration: duration)
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
    
    // MARK: View lifecycle
    
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
    var timerReady: Bool {return (buttonStatus == .change)}
    
    /**
     Updates the timer display with a time interval.
     - parameter seconds: time remaining as a `TimeInterval`
     */
    func updateDisplay(with seconds: TimeInterval) {
        timeDisplay.text = displayStack.display(time: seconds)
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
            containerView.accessibilityLabel = DisplayStack.containerViewLabel(timerReady: (status != .start), timerDuration: duration)
            instructionsVisible = (status != .start)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
        
        switch status {
        case .start: notifyUserOfTimerStatus(notice: DisplayStack.timerStarted, sound: .startCue)
        case .end: notifyUserOfTimerStatus(notice: DisplayStack.timerEnded, sound: .endCue)
        case .cancel: notifyUserOfTimerStatus(notice: DisplayStack.timerCancelled)
        }
    }
    
    /// Locks the stopwatch to prevent multiple timers from running simultaneously
    func lock() {setButton(to: .cancel)}
    
    /// Unlocks the stopwatch when no timer is running
    func unlock() {setButton(to: .change)}

    // This view controller can kill a running timer directly
    func killTimer() {
        if buttonStatus == .cancel {buttonActions()}
        soundController.play(.dieCue)
    }
}

// MARK: - VoiceOverObserver
// Receive notifications when VoiceOver status changes
extension MainViewController: VoiceOverObserver {
    /// Change the text instructions to match the VO-enabled interaction paradigm and make the containerView touch-enabled
    func voiceOverStatusDidChange(_: Notification? = nil) {
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        instructionsDisplay.text = DisplayStack.textInstructions(voiceOverOn: voiceOverOn)
        voiceOverOn ? containerView.addGestureRecognizer(tapRecognizer) : containerView.removeGestureRecognizer(tapRecognizer)
        containerView.layoutIfNeeded()
    }
}
