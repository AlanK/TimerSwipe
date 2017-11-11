//
//  NavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

protocol VoiceOverHandler {
    func customizeDisplayForVoiceOver(_: Notification?)
}

/// Root navigation controller for app
class NavController: UINavigationController {
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
    
    /// Make any necessary changes to views after being in the background for a long time
    func refreshViews() {
        // Don’t change views if a timer is running or there’s no favorite to change to
        guard timerNotRunning, let storyboard = storyboard, let _ = model.favorite() else {return}
        // Don't disrupt an active edit session
        if (topViewController as? TableController)?.isEditing == true {return}

        // Navigate to the favorite timer with the table view in the nav stack
        let tableVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        let mainVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)
        // Don't animate going from one timer to another; it looks weird
        let animate = !(topViewController is MainViewController)
        
        setViewControllers([tableVC, mainVC], animated: animate)
    }
}

// MARK: - Model Intermediary
// Make the model available to other objects
extension NavController: ModelIntermediary {}

// MARK: - StopwatchIntermediary

extension NavController: StopwatchIntermediary {
    var timerNotRunning: Bool {
        return (topViewController as? StopwatchIntermediary)?.timerNotRunning ?? true
    }
    
    func killTimer() {
        (topViewController as? StopwatchIntermediary)?.killTimer()
    }
}
