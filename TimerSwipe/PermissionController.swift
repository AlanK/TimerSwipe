//
//  PermissionController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/4/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class PermissionController: UIViewController {
    private static let permissionText = NSLocalizedString("permissionRequest", value: "TimerSwipe can alert you when your timer has finished, even if you are in another app and TimerSwipe is no longer running.\n\nIt must ask for your permission to enable or disable this feature.", comment: "")
    private static let doneText = NSLocalizedString("doneText", value: "You can turn local notifications on and off in the Settings app under Notifications → TimerSwipe.", comment: "")

    var permissionRequest: (() -> Void)?
    
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
        permissionRequest?()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = K.tintColor
        doneButton.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func transitionFromPermissionToDone() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.0) {
                self.permissionButton.isHidden = true
                self.doneButton.isHidden = false
            }
            UIView.animate(withDuration: 0.5) {
                self.textArea.text = PermissionController.doneText
            }
        }
    }
}
