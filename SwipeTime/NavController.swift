//
//  NavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit
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
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        
        guard let storyboard = storyboard else {return}
        // Make sure the table view is in the view hierarchy
        let tableVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        var navHierarchy = [tableVC]
        
        if let _ = model.favorite() {
            // If a favorite exists, navigate to the favorite timer
            let mainVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)
            navHierarchy.append(mainVC)
        }
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

// MARK: - Model Controller
// Make the model available to other objects
extension NavController: ModelController {}

// MARK: - StopwatchController

extension NavController: StopwatchController {
    var timerNotRunning: Bool {
        return (topViewController as? StopwatchController)?.timerNotRunning ?? true
    }
    
    func killTimer() {
        (topViewController as? StopwatchController)?.killTimer()
    }
}
