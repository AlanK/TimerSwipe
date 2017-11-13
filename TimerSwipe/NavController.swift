//
//  NavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

protocol VoiceOverObserver {
    func voiceOverStatusDidChange(_: Notification?)
}

/// Root navigation controller for app
class NavController: UINavigationController {
    
    private let notificationCenter = NotificationCenter.default
    
    /// Underlying model for app
    let model: STTimerList = {
        let model: STTimerList
        // Try to load the model from UserDefaults
        if let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data, let extractedModel = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList {
            model = extractedModel
        } else {
            // No model extracted; give up and load the default model
            model = STTimerList()
            model.loadSampleTimers()
        }
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barStyle = .black
        navigationBar.barTintColor = K.tintColor
        navigationBar.tintColor = .white
        
        // Make sure the table view is in the view hierarchy
        guard let storyboard = storyboard else {return}
        let tableVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        let navHierarchy = (model.favorite() == nil) ? [tableVC] :
            [tableVC, storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)]
        
        setViewControllers(navHierarchy, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        registerNotifications(false)
    }
    
    /// Make any necessary changes to views after being in the background for a long time
    func resetViewsAfterBackgroundTimeout() {
        // Don’t change views if a timer is running or there’s no favorite to change to
        guard timerReady, let storyboard = storyboard, let _ = model.favorite() else {return}
        // Don't disrupt an active edit session
        if (topViewController as? TableController)?.isEditing == true {return}

        // Navigate to the favorite timer with the table view in the nav stack
        let tableVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        let mainVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)
        // Don't animate going from one timer to another; it looks weird
        let animate = !(topViewController is MainViewController)
        
        setViewControllers([tableVC, mainVC], animated: animate)
    }
    
    private func registerNotifications(_ register: Bool) {
        let voiceOverNotice: NSNotification.Name
        if #available(iOS 11.0, *) {voiceOverNotice = .UIAccessibilityVoiceOverStatusDidChange}
        else {voiceOverNotice = NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged)}
        
        switch register {
        case true: notificationCenter.addObserver(forName: voiceOverNotice, object: nil, queue: nil, using: forwardVoiceOverNotification(_:))
        case false: notificationCenter.removeObserver(self, name: voiceOverNotice, object: nil)
        }
    }
    
    private func forwardVoiceOverNotification(_ notification: Notification) {
        guard let vc = topViewController as? VoiceOverObserver else {return}
        vc.voiceOverStatusDidChange(notification)
    }
}

// MARK: - Model Intermediary
// Make the model available to other objects
extension NavController: ModelIntermediary {}

// MARK: - StopwatchIntermediary

extension NavController: StopwatchIntermediary {
    var timerReady: Bool {
        return (topViewController as? StopwatchIntermediary)?.timerReady ?? true
    }
    
    func killTimer() {
        (topViewController as? StopwatchIntermediary)?.killTimer()
    }
}
