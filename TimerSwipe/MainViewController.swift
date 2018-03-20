//
//  MainViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UserNotifications
import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func swipe(_: MainViewController)
    func buttonActivated(_: UIButton, vc: MainViewController)
    func magicTapActivated(_ : MainViewController) -> Bool
    func accessibleEscapeActivated(_: MainViewController) -> Bool
    func containerViewAlternateActivated(_: MainViewController)
    func containerViewActivated(_: MainViewController, sender: UITapGestureRecognizer)
    func containerViewToggleActivated(_: MainViewController)
}

/// Primary view controller—displays the selected timer
class MainViewController: UIViewController {
    // MARK: Dependencies
    
    private weak var delegate: MainViewControllerDelegate!
    private var providedTimer: STSavedTimer!

    // MARK: Initializers
    
    static func instantiate(with delegate: MainViewControllerDelegate, timer: STSavedTimer) -> MainViewController {
        let storyboard = UIStoryboard(name: "MainViewController", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: MainID.mainView.rawValue) as! MainViewController
        
        vc.delegate = delegate
        vc.providedTimer = timer
        
        return vc
    }
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The display shouldn’t sleep while this view is visible since the user expects to start a timer when they can’t see the screen
        UIApplication.shared.isIdleTimerDisabled = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        soundController.setActive(true)
        handleVoiceOverStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The display should sleep in other views in the app
        UIApplication.shared.isIdleTimerDisabled = false
        soundController.setActive(false)
    }
    
    override func accessibilityPerformMagicTap() -> Bool { return delegate.magicTapActivated(self) }
    
    override func accessibilityPerformEscape() -> Bool { return delegate.accessibleEscapeActivated(self) }
    
    // MARK: Actions

    @IBAction func button(_ sender: AnyObject) { delegate.buttonActivated(button, vc: self) }
    
    // A swipe in any direction has the same effect.
    @IBAction func swipeRight(_ sender: AnyObject) { delegate.swipe(self) }
    @IBAction func swipeLeft(_ sender: AnyObject) { delegate.swipe(self) }
    @IBAction func swipeUp(_ sender: AnyObject) { delegate.swipe(self) }
    @IBAction func swipeDown(_ sender: AnyObject) { delegate.swipe(self) }
    
    @objc func containerViewActivated(sender: UITapGestureRecognizer) { delegate.containerViewActivated(self, sender: sender) }
    @objc func containerAlternateActivated() { delegate.containerViewAlternateActivated(self) }
    @objc func toggleAnnouncements() { delegate.containerViewToggleActivated(self) }
    
    // MARK: Outlets
    /// The "Swipe to Start" label
    @IBOutlet var instructionsDisplay: UILabel! {
        didSet { instructionsHandler.setText(voiceOverOn: UIAccessibilityIsVoiceOverRunning()) }
    }
    
    /// The "00:00.00" label
    @IBOutlet var timeDisplay: UILabel! {
        didSet {
            timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: 64.0, weight: UIFont.Weight.regular)
            // Get an initial value from the countdown
            countdown.wake()
        }
    }
    
    /// The Change/Cancel button
    @IBOutlet var button: UIButton! {
        didSet { setButtonTitle(button, withTimerReadyStatus: true) }
    }
    
    @IBOutlet var containerView: UIStackView! {
        didSet { containerHandler.configure(owner: self, duration: duration) }
    }
    
    // MARK: Properties
    
    lazy var countdown: Countdown = Countdown(delegate: self, duration: duration)
    
    var timeAnnouncementController = TimeAnnouncementController()
    private var appStateNotifications = AppStateNotifications()
    
    private lazy var duration = providedTimer.seconds
    private lazy var containerHandler = ContainerViewAccessorizer(containerView, vc: self)
    private lazy var instructionsHandler = InstructionsHandler(instructionsDisplay)

    private let soundController = SoundController()
    private let localNotifications = LocalNotifications()
    private let timeFormatter = TimeFormatter()
    
    let strings = MainVCStrings()
    
    
    // MARK: Methods
    
    private func setButtonTitle(_ button: UIButton, withTimerReadyStatus timerIsReady: Bool) {
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            button.setTitle(strings.buttonText(timerIsReady: timerIsReady), for: UIControlState())
            button.layoutIfNeeded()
        }
    }
    
    private func handleVoiceOverStatus() {
        /// Change the text instructions to match the VO-enabled interaction paradigm and make the containerView touch-enabled
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        instructionsHandler.setText(voiceOverOn: voiceOverOn)
        containerHandler.voiceOver(voiceOverOn: voiceOverOn)
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
                timeAnnouncementController.startTimeAnnouncements(for: expirationDate, duration: duration)
            case .end, .cancel, .expire: isReady = true
                appStateNotifications.removeAll()
                localNotifications.disableNotification()
                timeAnnouncementController.cancelTimeAnnouncements()
            }
            
            setButtonTitle(button, withTimerReadyStatus: isReady)
            containerHandler.label(timerReady: isReady, duration: duration)
            instructionsHandler.animate(to: isReady)
            
            if let sound = sound { soundController.play(sound) }
            
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
    func voiceOverStatusDidChange(_: Notification? = nil) { handleVoiceOverStatus() }
}
