//
//  MainNavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController {
    var model: STTimerList?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let archivedData = UserDefaults.standard.object(forKey: K.persistedList) as? Data {
            model = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? STTimerList
        } else {
            model = STTimerList()
            model?.loadSampleTimers()
        }
        
        // Navigate to the correct entry point
        let tableView = self.storyboard!.instantiateViewController(withIdentifier: StoryboardID.tableView.rawValue)
        guard model?.favorite() != nil else {
            self.setViewControllers([tableView], animated: false)
            return
        }
        self.setViewControllers([tableView, self.storyboard!.instantiateViewController(withIdentifier: StoryboardID.mainView.rawValue)], animated: false)
    }
}

extension MainNavController: ModelController {}
