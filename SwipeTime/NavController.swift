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
    var model: STTimerList?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Try to load the model from UserDefaults
        if let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data {
            model = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList
        } else {
            // No model in UserDefaults; give up and load the sample timers instead
            model = STTimerList()
            model?.loadSampleTimers()
        }
        
        // Navigate to the correct entry point
        guard let storyboard = self.storyboard else {return}
        let tableView = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        guard let _ = model?.favorite() else {
            // No favorite timer; give up and load the table view
            self.setViewControllers([tableView], animated: false)
            return
        }
        // Navigate to the favorite timer with the table view in the nav stack
        self.setViewControllers([tableView, storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)], animated: false)
    }
    
    func refreshViews() {
        // Animate changes in views
        var animate = true
        // Ensure there is a storyboard and a favorite timer
        guard let storyboard = self.storyboard, let _ = model?.favorite() else {return}
        if self.topViewController is MainViewController {
            // Don't animate going from one timer to another; it looks weird
            animate = false
        }
        let tableView = storyboard.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        // Navigate to the favorite timer with the table view in the nav stack
        self.setViewControllers([tableView, storyboard.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)], animated: animate)
        
    }
}

// Make the model available to other objects
extension NavController: ModelController {}
