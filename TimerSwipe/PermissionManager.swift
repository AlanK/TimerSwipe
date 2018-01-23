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
    private let center = UNUserNotificationCenter.current()
    private unowned var parentVC: UIViewController
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        getNotificationAuthorizationStatus()
    }
    
    private func getNotificationAuthorizationStatus() {
        center.getNotificationSettings() { (settings) in
            
            switch settings.authorizationStatus {
            case .notDetermined: self.notificationsNotDetermined()
            case .denied: self.notificationsDenied()
            case .authorized: self.notificationsAuthorized()
            }
        }
    }
    
    private func notificationsNotDetermined() {
        let presenter = PermissionController.instantiate(with: self)
        DispatchQueue.main.async {
            self.parentVC.showDetailViewController(presenter, sender: nil)
        }
    }
    
    private func notificationsDenied() { }
    
    private func notificationsAuthorized() {
        let timerCompleteCategory = UNNotificationCategory(identifier: "TimerCompleteCategory", actions: [], intentIdentifiers: [])
        center.setNotificationCategories([timerCompleteCategory])
    }
}

extension PermissionManager: PermissionControllerDelegate {
    func askMyPermission(_ permissionController: PermissionController) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { (isAuthorized, error) in
            if let error = error { print(error) }
            
            permissionController.wrapUp()
            isAuthorized ? self.notificationsAuthorized() : self.notificationsDenied()
        }
    }
    
    func done(_ permissionController: PermissionController) {
        permissionController.dismiss(animated: true, completion: nil)
    }
}
