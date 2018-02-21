//
//  PermissionController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/4/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

/// Handles the actions of a `PermissionController`
protocol PermissionControllerDelegate {
    /**
     Ask the user for permission to display local notifications
     - parameter permissionController: This permission controller
     */
    func askMyPermission(_ permissionController: PermissionController)
    /**
     Do any cleanup and dismiss the `PermissionController`
     - parameter permissionController: This permission controller
     */
    func done(_ permissionController: PermissionController)
}

// MARK: -

class PermissionController: UIViewController {
    // MARK: Dependencies
    /// Handles any actions triggered on this view controller
    private var delegate: PermissionControllerDelegate!
    
    // MARK: Initializers
    /**
     Instantiates a fully-configured `PermissionController` with `PermissionControllerDelegate` injected
     - parameter delegate: An instance of a type conforming to the `PermissionControllerDelegate` protocol
     */
    static func instantiate(with delegate: PermissionControllerDelegate) -> PermissionController {
        let storyboard = UIStoryboard.init(name: Storyboards.permissions.rawValue, bundle: Bundle.main)
        let pc = storyboard.instantiateViewController(withIdentifier: PermissionsID.permissionController.rawValue) as! PermissionController
        pc.delegate = delegate
        return pc
    }
    
    // MARK: Properties
    /// Makes status bar text white with a transparent background
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet var mainView: UIView! {
        didSet { mainView.backgroundColor = K.tintColor }
    }
    
    @IBOutlet var textArea: UITextView! {
        didSet {
            textArea.text = NSLocalizedString("TimerSwipe can alert you when your timer has finished, even if you are in another app.\n\nIt must ask for your permission to enable or disable this feature.", comment: "")
        }
    }
    
    @IBOutlet var permissionButton: UIButton! {
        didSet { permissionButton.lightButtonStyle() }
    }
    
    @IBOutlet var doneButton: UIButton! {
        didSet { doneButton.lightButtonStyle() }
    }
    
    // MARK: Actions
    
    @IBAction func permissionButtonAction(_ sender: Any) { delegate.askMyPermission(self) }
    
    @IBAction func doneButtonAction(_ sender: Any) { delegate.done(self) }
    
    // MARK: Methods
    /// Advance this permission controller from its initial state to its final state
    func wrapUp() {
        UIView.animate(withDuration: 0.0, animations: {
            self.permissionButton.isHidden = true
            self.doneButton.isHidden = false
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: K.keyboardAnimationDuration) {
                self.textArea.text = NSLocalizedString("You can turn local notifications on or off in the Settings app under Notifications → TimerSwipe.",
                                                       comment: "")
                self.view.layoutIfNeeded()
            }
        }
    }
}
