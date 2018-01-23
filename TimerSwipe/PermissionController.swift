//
//  PermissionController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/4/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

protocol PermissionControllerDelegate {
    func askMyPermission(_ permissionController: PermissionController)
    func done(_ permissionController: PermissionController)
}

class PermissionController: UIViewController {
    private static let permissionText = NSLocalizedString("permissionRequest", value: "TimerSwipe can alert you when your timer has finished, even if you are in another app and TimerSwipe is no longer running.\n\nIt must ask for your permission to enable or disable this feature.", comment: "")
    private static let doneText = NSLocalizedString("doneText", value: "You can turn local notifications on and off in the Settings app under Notifications → TimerSwipe.", comment: "")
    
    static func instantiate(with delegate: PermissionControllerDelegate) -> PermissionController {
        let storyboard = UIStoryboard.init(name: Storyboards.permissions.rawValue, bundle: Bundle.main)
        let pc = storyboard.instantiateViewController(withIdentifier: PermissionsID.permissionController.rawValue) as! PermissionController
        pc.delegate = delegate
        return pc
    }

    private var delegate: PermissionControllerDelegate!
    
    @IBOutlet var textArea: UITextView! {
        didSet {
            textArea.text = PermissionController.permissionText
        }
    }
    @IBOutlet var permissionButton: UIButton! {
        didSet {
            permissionButton.lightButtonStyle()
        }
    }
    @IBOutlet var doneButton: UIButton! {
        didSet {
            doneButton.lightButtonStyle()
        }
    }
    
    @IBAction func permissionButtonAction(_ sender: Any) {
        delegate.askMyPermission(self)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        delegate.done(self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = K.tintColor
        doneButton.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func wrapUp() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.0) {
                self.permissionButton.isHidden = true
                self.doneButton.isHidden = false
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: K.keyboardAnimationDuration) {
                self.textArea.text = PermissionController.doneText
                self.view.layoutIfNeeded()
            }
        }
    }
}
