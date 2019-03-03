//
//  Notifications.swift
//  OneMoreAlarm
//
//  Created by  William on 3/3/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications: NSObject {
    var notificationCenter = UNUserNotificationCenter.current()
    
    func requestPermissions() {
        notificationCenter.getNotificationSettings { [unowned notificationCenter] settings in
            guard settings.authorizationStatus != .authorized else {
                return
            }
            
            notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in
                if granted {
                    print("Application is not authorized to send notififcations")
                }
            }
        }
    
    }
    
    func scheduleNotification(withText: String, timeInterval: TimeInterval) -> String? {
        requestPermissions()
        
        let content = UNMutableNotificationContent()
        content.title = "Alarm notification"
        content.body = withText
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let requestId = UUID().uuidString
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if error != nil {
                print("Unable to schedule notification. \(error!.localizedDescription)")
            }
        }
        
        return requestId
    }
    
    func unscheduleNotification(withRequestID: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [withRequestID])
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    // Show notifications when the app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // perform notification
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // TODO
        completionHandler()
    }
}


