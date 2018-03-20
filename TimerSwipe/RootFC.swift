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
        _ = TimeoutManager { [unowned self] in
            // TODO: Refactor this.
            
            let topVC = self.nav.topViewController
            let model = self.model!
            
            // Don’t change views if a timer is running or there’s no favorite to change to
            guard (topVC as? CountdownDelegate)?.countdownIsReady ?? true, let _ = model.favorite else { return }
            // Don't disrupt an active edit session
            if (topVC as? TableController)?.isEditing == true { return }
            
            // Don't animate going from one timer to another; it looks weird
            let animated = !(topVC is MainViewController)
            self.loadNavigationStack(animated: animated, with: model)
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
        if let countdownDelegate = nav.topViewController as? CountdownDelegate, countdownDelegate.countdownIsReady == false {
            countdownDelegate.cancelCountdown()
        }
        
        let vc = TableController.instantiate(with: self, model: model)
        var navHierarchy: [UIViewController] = [vc]
        
        if let providedTimer = providedTimer ?? model.favorite {
            let vc = MainViewController.instantiate(with: self, timer: providedTimer)
            navHierarchy.append(vc)
        }
        nav.setViewControllers(navHierarchy, animated: animated)
    }
}

extension RootFC: TableControllerDelegate {
    func tableView(_ model: Model, tableController: TableController, didSelectRowAt indexPath: IndexPath) {
        let timer = model[indexPath.row]
        let vc = MainViewController.instantiate(with: self, timer: timer)
        nav.pushViewController(vc, animated: true)
    }
}

extension RootFC: MainViewControllerDelegate {
    private func changeTimerOrCancelCountdown(_ vc: MainViewController) { vc.countdownIsReady ? leaveMainViewController() : vc.cancelCountdown() }
    
    private func startOrEndCountdown(_ vc: MainViewController) { vc.countdownIsReady ? vc.startCountdown() : vc.cancelCountdown() }
    
    private func leaveMainViewController() { _ = nav.popViewController(animated: true) }
    
    func swipe(_ vc: MainViewController) { vc.startCountdown() }
    
    func buttonActivated(_ button: UIButton, vc: MainViewController) { changeTimerOrCancelCountdown(vc) }
    
    func containerViewAlternateActivated(_ vc: MainViewController) { changeTimerOrCancelCountdown(vc) }

    func accessibleEscapeActivated(_ vc: MainViewController) -> Bool {
        changeTimerOrCancelCountdown(vc)
        return true
    }
    
    func magicTapActivated(_ vc: MainViewController) -> Bool {
        startOrEndCountdown(vc)
        return true
    }
    
    func containerViewActivated(_ vc: MainViewController, sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {return}
        startOrEndCountdown(vc)
    }
    
    func containerViewToggleActivated(_ vc: MainViewController) { vc.timeAnnouncementController.togglePreference() }
}
