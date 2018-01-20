//
//  PermissionManager.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 1/3/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UserNotifications
import UIKit

protocol PermissionDelegate: class {
    func request(handler: @escaping () -> Void)
    func wrapUp()
}

typealias PermissionPresenter = UIViewController & PermissionDelegate

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
        let storyboard = UIStoryboard.init(name: "Permissions", bundle: Bundle.main)
        
        guard let presenter = storyboard.instantiateViewController(withIdentifier: "PermissionController") as? PermissionPresenter else { return }
        presenter.request {
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { (isAuthorized, error) in
                if let error = error { print(error) }
                
                presenter.wrapUp()
                
                isAuthorized ? self.notificationsAuthorized() : self.notificationsDenied()
            }
        }
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
