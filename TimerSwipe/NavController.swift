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
    var model: Model!
    
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
}
