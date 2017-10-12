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
        // Try to load the model from UserDefaults
        guard let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data, let extractedModel = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList else {
            // No model extracted; give up and load the default model
            let model = STTimerList()
            model.loadSampleTimers()
            return model
        }
        return extractedModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        
        guard let storyboard = self.storyboard else {return}
        // Make sure the table view is in the view hierarchy
        let tableVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        var navHierarchy = [tableVC]
        
        if let _ = model.favorite() {
            // If a favorite exists, navigate to the favorite timer
            let mainVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)
            navHierarchy.append(mainVC)
        }
        self.setViewControllers(navHierarchy, animated: false)
    }
    
    /// Make any necessary changes to views after being in the background for a long time
    func refreshViews() {
        // Animate changes in views
        let animate: Bool
        // Ensure there is a storyboard and a favorite timer
        guard let storyboard = self.storyboard, let _ = model.favorite() else {return}
        // Don't disrupt an active edit session
        if let vc = self.topViewController as? TableController {
            guard vc.isEditing == false else {return}
        }
        if self.topViewController is MainViewController {
            // Don't animate going from one timer to another; it looks weird
            animate = false
        } else {
            animate = true
        }
        let tableView = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        // Navigate to the favorite timer with the table view in the nav stack
        self.setViewControllers([tableView, storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)], animated: animate)
    }
}

// MARK: - Model Controller
// Make the model available to other objects
extension NavController: ModelController {}

// MARK: - Timeout Handler

extension NavController {
    var unlocked: Bool {
        guard let watch = topViewController as? StopwatchDelegate else {return true}
        return watch.unlocked
    }
    
    func killTimer() {
        guard let main = topViewController as? MainViewController else {return}
        main.killTimer()
    }
}
