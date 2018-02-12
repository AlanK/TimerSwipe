//
//  PermissionManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/3/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UserNotifications
import UIKit

struct PermissionManager {
    // MARK: Dependencies
    /// The view controller that owns the permission manager
    private unowned var parentVC: UIViewController
    
    // MARK: Initializers
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        getNotificationAuthorizationStatus()
    }
    
    // MARK: Properties
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: Methods
    
    /// Retrieves local notification preferences
    private func getNotificationAuthorizationStatus() {
        center.getNotificationSettings() { (settings) in
            
            switch settings.authorizationStatus {
            case .notDetermined: self.notificationsNotDetermined()
            case .denied: self.notificationsDenied()
            case .authorized: self.notificationsAuthorized()
            }
        }
    }
    
    /// Presents a permission controller modally if local notification preferences have never been set
    private func notificationsNotDetermined() {
        let vc = PermissionController.instantiate(with: self)
        DispatchQueue.main.async {
            self.parentVC.showDetailViewController(vc, sender: nil)
        }
    }
    
    /// Takes no action of local notifications are disabled
    private func notificationsDenied() { }
    
    
    /// Configures local notifications if they are enabled
    private func notificationsAuthorized() {
        let timerCompleteCategory = UNNotificationCategory(identifier: "TimerCompleteCategory", actions: [], intentIdentifiers: [])
        center.setNotificationCategories([timerCompleteCategory])
    }
}

// MARK: - Permission Controller Delegate
extension PermissionManager: PermissionControllerDelegate {
    // MARK: Methods
    
    func askMyPermission(_ permissionController: PermissionController) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { (isAuthorized, error) in
            if let error = error { print(error) }
            DispatchQueue.main.async {
                permissionController.wrapUp()
            }
            isAuthorized ? self.notificationsAuthorized() : self.notificationsDenied()
        }
    }
    
    func done(_ permissionController: PermissionController) {
        permissionController.dismiss(animated: true, completion: nil)
    }
}
