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
    
    private var model: Model!
    
    // MARK: Initializers
    
    static func instantiate(with model: Model) -> RootFC {
        let fc = RootFC.init(nibName: nil, bundle: nil)
        fc.model = model
        
        return fc
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        addChildToRootView(navController)
        
    }
    
    // MARK: Properties
    
    lazy var navController: NavController = {
        // I am handling initialization of the Nav Controller here instead of in the Nav Controller itself because my ultimate goal is to eliminate the Nav Controller and replace it with an ordinary UINavigationController.
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nc = storyboard.instantiateInitialViewController() as! NavController
        nc.model = model
        
        return nc
    }()
}
