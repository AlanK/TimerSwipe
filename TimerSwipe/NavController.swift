//
//  NavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

/// This protocol should be adopted by any object that wants to respond to changes in VoiceOver status
protocol VoiceOverObserver {
    /// This function is called whenever VoiceOver status changes and is passed the relevant notification
    func voiceOverStatusDidChange(_: Notification?)
}

/// Root navigation controller for app
class NavController: UINavigationController {
    
    private let notificationCenter = NotificationCenter.default
    
    /// Underlying model for app
    var model: Model!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barStyle = .black
        navigationBar.barTintColor = K.tintColor
        navigationBar.tintColor = .white
        
        _ = TimeoutManager { [unowned self] in
            // Make any necessary changes to views after being in the background for a long time
            
            // Don’t change views if a timer is running or there’s no favorite to change to
            guard (self.topViewController as? CountdownDelegate)?.countdown.ready ?? true, let _ = self.model.favorite else { return }
            // Don't disrupt an active edit session
            if (self.topViewController as? TableController)?.isEditing == true { return }
            // Don't animate going from one timer to another; it looks weird
            let animated = self.topViewController is MainViewController == false
            
            self.loadNavigationStack(animated: animated)
            
        }
        
        loadNavigationStack(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Registering and unregistering for notifications should be paired in viewWillAppear(_:) and viewWillDisappear(_:)
        registerNotifications(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        registerNotifications(false)
    }
    
    func loadNavigationStack(animated: Bool, with providedTimer: STSavedTimer? = nil) {
        // If there's a timer running, cancel it. Don't try to cancel it if it isn't, running, though, to avoid weird crashes on launch from a shortcut item.
        if let countdownDelegate = topViewController as? CountdownDelegate, countdownDelegate.countdown.ready == false {
            countdownDelegate.countdown.cancel()
        }
        
        guard let storyboard = storyboard else {return}
        // Make sure the table view is in the view hierarchy
        let tableVC = storyboard.instantiateViewController(withIdentifier: MainID.tableView.rawValue)
        
        guard let vc = tableVC as? TableController else { return }
        vc.model = model
        var navHierarchy: [UIViewController] = [vc]
        
        if let providedTimer = providedTimer ?? model.favorite {
            let mainVC = storyboard.instantiateViewController(withIdentifier: MainID.mainView.rawValue)
            
            guard let vc = mainVC as? MainViewController else { return }
            vc.providedTimer = providedTimer
            navHierarchy.append(vc)
        }
        setViewControllers(navHierarchy, animated: animated)
    }
    
    /// Register and unregister for notifications on behalf of other VCs
    private func registerNotifications(_ register: Bool) {
        // UIAccessibilityVoiceOverStatusChanged and NSNotification.Name.UIAccessibilityVoiceOverStatusDidChange are the same notification in iOS 10 and iOS 11
        let voiceOverNotice: NSNotification.Name
        if #available(iOS 11.0, *) { voiceOverNotice = .UIAccessibilityVoiceOverStatusDidChange }
        else { voiceOverNotice = NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged) }
        
        switch register {
        case true: notificationCenter.addObserver(forName: voiceOverNotice, object: nil, queue: nil, using: forwardVoiceOverNotification(_:))
        case false: notificationCenter.removeObserver(self, name: voiceOverNotice, object: nil)
        }
    }
    
    /// Forwards the UIAccessibilityVoiceOverStatusChanged/.UIAccessibilityVoiceOverStatusDidChange notification to the topmost VC if it conforms to the VoiceOverObserver protocol
    private func forwardVoiceOverNotification(_ notification: Notification) {
        guard let vc = topViewController as? VoiceOverObserver else { return }
        vc.voiceOverStatusDidChange(notification)
    }
}
