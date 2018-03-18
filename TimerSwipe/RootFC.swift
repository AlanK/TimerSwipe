//
//  RootFC.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/18/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class RootFC: UIViewController {
    // MARK: Dependencies
    
    // MARK: Initializers
    
    static func instantiate() -> RootFC {
        let fc = RootFC.init(nibName: nil, bundle: nil)
        return fc
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        addChildToRootView(navController)
        
    }
    
    // MARK: Properties
    
    lazy var navController: NavController = {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nc = storyboard.instantiateInitialViewController() as! NavController
        
        return nc
    }()
}
