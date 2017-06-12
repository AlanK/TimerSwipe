//
//  MainNavController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/12/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController {
    var model = STTimerList()

    override func viewDidLoad() {
        super.viewDidLoad()
        model.readData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MainNavController: ModelController {}
