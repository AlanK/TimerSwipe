//
//  MainViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UserNotifications
import UIKit

/// Primary view controller—displays the selected timer
class MainViewController: UIViewController {
    // MARK: Class Properties
    /// Font settings for the timer display
    private static let timeFont = UIFont.monospacedDigitSystemFont(ofSize: 64.0, weight: UIFont.Weight.regular)
    
    // MARK: - Instance
    
    private let timeFormatter = TimeFormatter()
    private let soundController = SoundController()
    private let strings = MainVCStrings()
    
    // MARK: Duration Properties
    var providedTimer: STSavedTimer?
    
    // Use a timer provided from elsewhere, then a default time
    private lazy var duration = providedTimer?.seconds ?? K.defaultDuration

    // MARK: Stopwatch Properties
    lazy var stopwatch: Stopwatch = Stopwatch.init(delegate: self, duration: duration)
    
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
    
    private lazy var containerViewAction = UIAccessibilityCustomAction.init(name: strings.buttonLabel(timerIsReady: stopwatch.ready), target: self, selector: #selector(buttonActions))

    
    // MARK: Labels & Buttons
    
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel! {
        didSet {
            instructionsDisplay.text = strings.textInstructions(voiceOverIsOn: false)
        }
    }
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel! {
        didSet {
            timeDisplay.font = MainViewController.timeFont
            // Get an initial value from the stopwatch
            stopwatch.wake()
        }
    }
    /// The Change/Cancel button
    @IBOutlet var button: UIButton!
    @IBOutlet var containerView: UIStackView! {
        didSet {
            containerView.isAccessibilityElement = true
            containerView.accessibilityTraits = UIAccessibilityTraitSummaryElement
            containerView.accessibilityCustomActions = [containerViewAction]
            containerView.accessibilityLabel = strings.containerViewLabel(timerReady: true, timerDuration: duration)
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
        stopwatch.ready ? start() : buttonActions()
        return true
    }
    
    @objc func containerViewAsButton(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {return}
        _ = accessibilityPerformMagicTap()
    }
    
    /// Tells the Stopwatch to start the timer
    private func start() {
        stopwatch.start()
        enableObservations()
    }
    
    /// Handles taps on the Change/Cancel button
    @objc private func buttonActions() {
        switch stopwatch.ready {
        // If the change button is tapped, go back one level in the view hierarchy
        case true: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case false: stopwatch.cancel()
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize display based on VoiceOver settings
        handleVoiceOverStatus()
        
        animateButton(withTimerReadyStatus: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The display shouldn’t sleep while this view is visible since the user expects to start a timer when they can’t see the screen
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        soundController.setActive(true)
        handleVoiceOverStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The display should sleep in other views in the app
        UIApplication.shared.isIdleTimerDisabled = false
        soundController.setActive(false)
    }
    
    private func animateButton(withTimerReadyStatus timerIsReady: Bool) {
        containerViewAction.name = strings.buttonLabel(timerIsReady: timerIsReady)
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.button.setTitle(strings.buttonText(timerIsReady: timerIsReady), for: UIControlState())
            self.button.layoutIfNeeded()
        }
    }
    
    private func enableObservations() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { _ in
            self.stopwatch.sleep()
        }
        nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            self.stopwatch.wake()
        }
    }
    
    private func disableObservations() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        nc.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    private func enableNotification(on expirationDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Timer Done", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "The timer has finished running.", arguments: nil)
        content.sound = UNNotificationSound(named: AudioCue.endCue.rawValue)
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: expirationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: K.notificationID, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error: Error?) in
            if let error = error { print(error) }
        }
    }
    
    private func disableNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [K.notificationID])
        center.removeDeliveredNotifications(withIdentifiers: [K.notificationID])
    }
    
    private func handleVoiceOverStatus() {
        /// Change the text instructions to match the VO-enabled interaction paradigm and make the containerView touch-enabled
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        instructionsDisplay.text = strings.textInstructions(voiceOverIsOn: voiceOverOn)
        voiceOverOn ? containerView.addGestureRecognizer(tapRecognizer) : containerView.removeGestureRecognizer(tapRecognizer)
        containerView.layoutIfNeeded()
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
        func updateTimerStatus(notice: String? = nil, sound: AudioCue? = nil) {
            if let sound = sound {
                soundController.play(sound)
            }
            
            let ready: Bool
            switch status {
            case .start: ready = false
            case .end, .cancel, .expire: ready = true
            }
            
            animateButton(withTimerReadyStatus: ready)
            containerView.accessibilityLabel = strings.containerViewLabel(timerReady: ready, timerDuration: duration)
            instructionsVisible = ready
            
            guard let notice = notice else { return }
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice)
        }
        
        switch status {
        case let .start(expirationDate): updateTimerStatus(notice: strings.timerStarted, sound: .startCue)
            enableNotification(on: expirationDate)
        case .end: updateTimerStatus(notice: strings.timerEnded, sound: .endCue)
            disableObservations()
            disableNotification()
        case .cancel: updateTimerStatus(notice: strings.timerCancelled)
            disableObservations()
            disableNotification()
        case .expire: updateTimerStatus()
            disableObservations()
            disableNotification()
        }
    }
}

// MARK: - VoiceOverObserver
// Receive notifications when VoiceOver status changes
extension MainViewController: VoiceOverObserver {
    func voiceOverStatusDidChange(_: Notification? = nil) {
        handleVoiceOverStatus()
    }
}