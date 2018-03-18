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
        super.viewDidLoad()
        
        _ = PermissionManager(parentVC: self)
        
        nav.loadNavigationStack(animated: false)
        addChildToRootView(nav)
        
        // Make any necessary changes to views after being in the background for a long time
        let n = nav
        let model = self.model!
        _ = TimeoutManager {
            // TODO: Refactor this.
            
            // Don’t change views if a timer is running or there’s no favorite to change to
            guard (n.topViewController as? CountdownDelegate)?.countdown.ready ?? true, let _ = model.favorite else { return }
            // Don't disrupt an active edit session
            if (n.topViewController as? TableController)?.isEditing == true { return }
            
            // Don't animate going from one timer to another; it looks weird
            let animated = !(n.topViewController is MainViewController)
            n.loadNavigationStack(animated: animated)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure registering is paired with unregistering in viewWillDisappear
        voiceOverHandler.registerNotifications(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure unregistering is paired with registering in viewWillAppear
        voiceOverHandler.registerNotifications(false)
    }
    
    // MARK: Properties
    
    lazy var nav: NavController = {
        // I am handling initialization of the Nav Controller here instead of in the Nav Controller itself because my ultimate goal is to eliminate the Nav Controller and replace it with an ordinary UINavigationController.
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nc = storyboard.instantiateInitialViewController() as! NavController
        nc.model = model
        
        nc.navigationBar.barStyle = .black
        nc.navigationBar.barTintColor = K.tintColor
        nc.navigationBar.tintColor = .white
        
        return nc
    }()
    
    private lazy var voiceOverHandler = VoiceOverHandler() { [unowned self] in return self.nav.topViewController as? VoiceOverObserver }

}
