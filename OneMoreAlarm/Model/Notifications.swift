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
    private(set) static var current: Notifications!
    
    var notificationCenter = UNUserNotificationCenter.current()
    
    struct Action {
        static let open = "OPEN_ACTION"
        static let confirm = "CONFIRM_ACTION"
        static let snooze = "SNOOZE_ACTION"
    }
    
    struct Category {
        static let alarm = "ALARM_NOTIFICATION"
    }
    
    static func prepare() {
        Notifications.current = Notifications()
        
        let openAction = UNNotificationAction(identifier: Action.open, title: "Open App", options: [.foreground])
        let confirmAction = UNNotificationAction(identifier: Action.confirm, title: "Confirm", options: [.destructive])
        let snoozeAction = UNNotificationAction(identifier: Action.snooze, title: "Snooze")
        let actions = [openAction, confirmAction, snoozeAction]
        
        let notificationCategory = UNNotificationCategory(identifier: Category.alarm, actions: actions, intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "%u alarms", options: .customDismissAction)
        Notifications.current.notificationCenter.setNotificationCategories([notificationCategory])
        
        Notifications.current.notificationCenter.delegate = Notifications.current
    }

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
    
    func scheduleNotification(withText: String, date: Date) -> String {
        requestPermissions()
        
        let content = UNMutableNotificationContent()
        content.body = withText
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = Category.alarm
        
        var notificationDate = DateComponents()
        notificationDate.hour = Calendar.current.component(.hour, from: date)
        notificationDate.minute = Calendar.current.component(.minute, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        
        let requestId = UUID().uuidString
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if error != nil {
                print("Unable to schedule notification. \(error!.localizedDescription)")
            }
        }
        
        return requestId
    }
    
    func scheduleNotification(withText: String, timeInterval: TimeInterval) -> String? {
        requestPermissions()
        
        let content = UNMutableNotificationContent()
        content.title = "Alarm notification"
        content.body = withText
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = Category.alarm
        
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
    
    func unscheduleNotification(withRequestId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [withRequestId])
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    // Show notifications when the app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // perform notification
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Notification dismissed")
        case UNNotificationDefaultActionIdentifier:
            print("Default notification action selected")
        
        case Action.open:
            print("'Open' notification action selected")
        case Action.confirm:
            print("'Confirm' notification action selected")
        case Action.snooze:
            print("'Snooze' notification action selected")
            let _ = scheduleNotification(withText: "Znoozed notification", timeInterval: 5)
            
        default:
            print("Unknown notification action selected")
        }
        
        completionHandler()
    }
}


