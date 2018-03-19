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
    
    override var childViewControllerForStatusBarStyle: UIViewController? { return nav }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = PermissionManager(parentVC: self)
        
        loadNavigationStack(animated: false, with: model)
        addChildToRootView(nav)
        
        // Make any necessary changes to views after being in the background for a long time
        let n = nav
        let m = self.model!
        _ = TimeoutManager { [unowned self] in
            // TODO: Refactor this.
            
            // Don’t change views if a timer is running or there’s no favorite to change to
            guard (n.topViewController as? CountdownDelegate)?.countdown.ready ?? true, let _ = m.favorite else { return }
            // Don't disrupt an active edit session
            if (n.topViewController as? TableController)?.isEditing == true { return }
            
            // Don't animate going from one timer to another; it looks weird
            let animated = !(n.topViewController is MainViewController)
            self.loadNavigationStack(animated: animated, with: m)
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
    
    let nav: UINavigationController = {
        let nc = UINavigationController()
        
        nc.navigationBar.barStyle = .black
        nc.navigationBar.barTintColor = K.tintColor
        nc.navigationBar.tintColor = .white
        
        return nc
    }()
    
    private lazy var voiceOverHandler = VoiceOverHandler() { [unowned self] in return self.nav.topViewController as? VoiceOverObserver }
    
    // MARK: Methods
    
    func loadNavigationStack(animated: Bool, with model: Model, providedTimer: STSavedTimer? = nil) {
        // If there's a timer running, cancel it. Don't try to cancel it if it isn't, running, though, to avoid weird crashes on launch from a shortcut item.
        if let countdownDelegate = nav.topViewController as? CountdownDelegate, countdownDelegate.countdown.ready == false {
            countdownDelegate.countdown.cancel()
        }
        
        let storyboard = UIStoryboard.init(name: "TableController", bundle: Bundle.main)
        // Make sure the table view is in the view hierarchy
        let tableVC = storyboard.instantiateViewController(withIdentifier: MainID.tableView.rawValue)
        
        guard let vc = tableVC as? TableController else { return }
        vc.model = model
        var navHierarchy: [UIViewController] = [vc]
        
        if let providedTimer = providedTimer ?? model.favorite {
            let storyboard = UIStoryboard.init(name: "MainViewController", bundle: Bundle.main)
            let mainVC = storyboard.instantiateViewController(withIdentifier: MainID.mainView.rawValue)
            
            guard let vc = mainVC as? MainViewController else { return }
            vc.providedTimer = providedTimer
            navHierarchy.append(vc)
        }
        nav.setViewControllers(navHierarchy, animated: animated)
    }
}
