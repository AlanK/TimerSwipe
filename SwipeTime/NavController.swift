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
    
    var unlocked: Bool {
        guard let watch = topViewController as? StopwatchDelegate else {return true}
        return watch.unlocked
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        
        // Navigate to the correct entry point
        guard let storyboard = self.storyboard else {return}
        let tableView = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        guard let _ = model.favorite() else {
            // No favorite timer; give up and load the table view
            self.setViewControllers([tableView], animated: false)
            return
        }
        // Navigate to the favorite timer with the table view in the nav stack
        self.setViewControllers([tableView, storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)], animated: false)
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
    
    func killTimer() {
        guard let main = topViewController as? MainViewController else {return}
        main.killTimer()
    }
}

// MARK: - Model Controller
// Make the model available to other objects
extension NavController: ModelController {}
