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
    private let localNotifications = LocalNotifications()
    private let strings = MainVCStrings()
    
    private var appStateNotifications = AppStateNotifications()
    private var announcementPreference = TimeAnnouncementPreference()
    private var timeRemainingAnnouncements = [Timer]()

    // MARK: Duration Properties
    var providedTimer: STSavedTimer?
    
    // Use a timer provided from elsewhere, then a default time
    private lazy var duration = providedTimer?.seconds ?? K.defaultDuration

    // MARK: Stopwatch Properties
    lazy var countdown: Countdown = Countdown.init(delegate: self, duration: duration)
    
    // MARK: Visual Configuration
    private func configureButton(withTimerReadyStatus timerIsReady: Bool) {
        primaryContainerAction.name = strings.buttonLabel(timerIsReady: timerIsReady)
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.button.setTitle(strings.buttonText(timerIsReady: timerIsReady), for: UIControlState())
            self.button.layoutIfNeeded()
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
            // Get an initial value from the countdown
            countdown.wake()
        }
    }
    /// The Change/Cancel button
    @IBOutlet var button: UIButton! {
        didSet { configureButton(withTimerReadyStatus: true) }
    }
    @IBOutlet var containerView: UIStackView! {
        didSet {
            containerView.isAccessibilityElement = true
            containerView.accessibilityTraits = UIAccessibilityTraitSummaryElement
            containerView.accessibilityCustomActions = [primaryContainerAction, toggleAnnouncementsAction]
            containerView.accessibilityLabel = strings.containerViewLabel(timerReady: true, timerDuration: duration)
        }
    }
    
    // MARK: Actions
    
    private lazy var tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(containerViewAsButton(sender:)))
    
    private lazy var primaryContainerAction = UIAccessibilityCustomAction.init(name: strings.buttonLabel(timerIsReady: countdown.ready), target: self, selector: #selector(buttonActions))
    
    private lazy var toggleAnnouncementsAction = UIAccessibilityCustomAction.init(name: strings.preferenceInstructions(currentStatus: announcementPreference.preference), target: self, selector: #selector(toggleAnnouncements))
    
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
        countdown.ready ? start() : buttonActions()
        return true
    }
    
    @objc func containerViewAsButton(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {return}
        _ = accessibilityPerformMagicTap()
    }
    
    /// Tells the Stopwatch to start the timer
    private func start() {
        countdown.start()
    }
    
    /// Handles taps on the Change/Cancel button
    @objc private func buttonActions() {
        switch countdown.ready {
        // If the change button is tapped, go back one level in the view hierarchy
        case true: self.navigationController?.popViewController(animated: true)
        // If the cancel button is tapped, call setButton(to:) to interrupt the running timer and change the text on the button
        case false: countdown.cancel()
        }
    }
    
    @objc private func toggleAnnouncements() -> Bool {
        announcementPreference.preference = !(announcementPreference.preference)
        toggleAnnouncementsAction.name = strings.preferenceInstructions(currentStatus: announcementPreference.preference)
        
        print(announcementPreference.preference)
        
        return true
    }
    
    // MARK: Utilities
    
    private func handleVoiceOverStatus() {
        /// Change the text instructions to match the VO-enabled interaction paradigm and make the containerView touch-enabled
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        instructionsDisplay.text = strings.textInstructions(voiceOverIsOn: voiceOverOn)
        voiceOverOn ? containerView.addGestureRecognizer(tapRecognizer) : containerView.removeGestureRecognizer(tapRecognizer)
        containerView.layoutIfNeeded()
    }
    
    private func configureTimeAnnouncements(for expirationDate: Date) {
        var announcementTimes = [3.0, 2.0, 1.0]
        
        if duration >= 15.0 { announcementTimes.append(10.0)}
        if duration >= 45.0 { announcementTimes.append(30.0) }
        if duration >= 120.0 {
            var secondsIndex = 60.0
            
            while secondsIndex + 60.0 <= duration {
                announcementTimes.append(secondsIndex)
                secondsIndex += 60.0
            }
        }
        
        for timeRemaining in announcementTimes {
            let dateOfAnnouncement = expirationDate - timeRemaining
            let timeFromNow = dateOfAnnouncement.timeIntervalSince(Date())
            let timer = Timer.scheduledTimer(withTimeInterval: timeFromNow, repeats: false) {_ in
                guard self.announcementPreference.preference else { return }
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.strings.timeRemaining(timeRemaining))
            }
            
            timeRemainingAnnouncements.append(timer)
        }
    }
    
    private func cancelTimeAnnouncements() {
        for timer in timeRemainingAnnouncements {
            timer.invalidate()
        }
        timeRemainingAnnouncements.removeAll()
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize display based on VoiceOver settings
        handleVoiceOverStatus()
        
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
}

// MARK: - Stopwatch delegate

extension MainViewController: CountdownDelegate {
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
    func countdownDid(_ status: CountdownStatus) {
        func updateTimerStatus(notice: String? = nil, sound: AudioCue? = nil) {
            let isReady: Bool
            switch status {
            case let .start(expirationDate): isReady = false
                appStateNotifications.add(onBackground: countdown.sleep, onActive: countdown.wake)
                localNotifications.enableNotification(on: expirationDate)
                configureTimeAnnouncements(for: expirationDate)
            case .end, .cancel, .expire: isReady = true
                appStateNotifications.removeAll()
                localNotifications.disableNotification()
                cancelTimeAnnouncements()
            }
            
            configureButton(withTimerReadyStatus: isReady)
            containerView.accessibilityLabel = strings.containerViewLabel(timerReady: isReady, timerDuration: duration)
            instructionsVisible = isReady
            
            if let sound = sound {
                soundController.play(sound)
            }
            
            if let notice = notice {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice)
            }
        }
        
        switch status {
        case .start: updateTimerStatus(notice: strings.timerStarted, sound: .startCue)
        case .end: updateTimerStatus(notice: strings.timerEnded, sound: .endCue)
        case .cancel: updateTimerStatus(notice: strings.timerCancelled)
        case .expire: updateTimerStatus()
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
