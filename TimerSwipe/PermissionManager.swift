//
//  PermissionManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/3/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UserNotifications
import UIKit

class PermissionManager: NSObject {
    private let center = UNUserNotificationCenter.current()
    private unowned let parentVC: UIViewController
    
    private weak var permissionController: PermissionController?
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        super.init()
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
        let storyboard = UIStoryboard.init(name: "Permissions", bundle: Bundle.main)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PermissionController") as? PermissionController else { return }
        vc.permissionRequest = self.requestNotificationAuthorization
        permissionController = vc
        
        DispatchQueue.main.async {
            self.parentVC.showDetailViewController(vc, sender: nil)
        }
    }
    
    private func notificationsDenied() {
        
    }
    
    private func notificationsAuthorized() {
        let timerCompleteCategory = UNNotificationCategory(identifier: "TimerCompleteCategory", actions: [], intentIdentifiers: [])
        center.setNotificationCategories([timerCompleteCategory])
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { (isAuthorized, error) in
            if let error = error { print(error) }
            
            self.permissionController?.transitionFromPermissionToDone()
            self.permissionController = nil
            
            isAuthorized ? self.notificationsAuthorized() : self.notificationsDenied()
        }
    }
}
