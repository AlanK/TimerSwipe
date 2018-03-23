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
    private var soundController = SoundController()
    private var appStateNotifications = AppStateNotifications()
    
    private let nav = UINavigationController.instantiateWithTSStyle()

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
        
        appStateNotifications.add(onBackground: { [unowned self] in
            if self.soundController.isActive { self.soundController.setActive(false) }
        }) { [unowned self] in
            self.setSoundControllerStatus()
        }
        
        // Make any necessary changes to views after being in the background for a long time
        _ = TimeoutManager { [unowned self] in
            let topVC = self.nav.topViewController, model = self.model!
            
            // Don’t change views if a timer is running
            if let vc = topVC as? CountdownDelegate {
                guard vc.countdownIsReady else { return }
            }
            // Don't change views if there is no favorite to change to
            guard let _ = model.favorite else { return }
            // Don't disrupt an active edit session
            if let vc = topVC as? TableController {
                if vc.isEditing { return }
            }
            
            // Don't animate going from one timer to another; it looks weird
            let leavingTableController = !(topVC is MainViewController)
            self.loadNavigationStack(animated: leavingTableController, with: model)
        }
    }
    
    deinit { appStateNotifications.removeAll() }

    // MARK: Properties
    
    private var needsSound: Bool { return (nav.topViewController as? SoundClient)?.needsSound ?? false }
    
    // MARK: Methods
    
    func launchTimer(_ timer: STSavedTimer) { loadNavigationStack(animated: false, with: model, timer: timer) }
    
    private func loadNavigationStack(animated: Bool, with model: Model, timer: STSavedTimer? = nil) {
        // If there's a timer running, cancel it. Don't try to cancel it if it isn't, running, though, to avoid weird crashes on launch from a shortcut item.
        if let countdownDelegate = nav.topViewController as? CountdownDelegate, countdownDelegate.countdownIsReady == false {
            countdownDelegate.cancelCountdown()
        }
        
        let vc = TableController.instantiate(with: self, model: model)
        var navHierarchy: [UIViewController] = [vc]
        
        if let timer = timer ?? model.favorite {
            let vc = MainViewController.instantiate(with: self, sound: soundController, timer: timer)
            navHierarchy.append(vc)
        }
        
        nav.setViewControllers(navHierarchy, animated: animated)
        setSoundControllerStatus()
    }
    
    private func setSoundControllerStatus() {
        guard soundController.isActive == needsSound else {
            soundController.setActive(needsSound)
            return
        }
    }
}

// MARK: - TableControllerDelegate

extension RootFC: TableControllerDelegate {
    func addButtonActivated(_: Any, tableController: TableController) { tableController.makeKAV(visible: true) }
    
    func tableView(_ model: Model, tableController: TableController, didSelectRowAt indexPath: IndexPath) {
        let timer = model[indexPath.row]
        let vc = MainViewController.instantiate(with: self, sound: soundController, timer: timer)
        nav.pushViewController(vc, animated: true)
        setSoundControllerStatus()
    }
}

// MARK: - MainViewControllerDelegate

extension RootFC: MainViewControllerDelegate {
    private func changeTimerOrCancelCountdown(_ vc: CountdownDelegate) { vc.countdownIsReady ? popVC() : vc.cancelCountdown() }
    
    private func startOrEndCountdown(_ vc: CountdownDelegate) { vc.countdownIsReady ? vc.startCountdown() : vc.cancelCountdown() }
    
    private func popVC() {
        _ = nav.popViewController(animated: true)
        setSoundControllerStatus()
    }
    
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
    
    func containerViewToggleActivated(_ vc: MainViewController) { vc.toggleTimeAnnouncementPreference() }
}
