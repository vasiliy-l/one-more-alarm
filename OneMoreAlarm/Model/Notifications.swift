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
    private var notificationCenter = UNUserNotificationCenter.current()
    
    struct Action {
        static let open = "OPEN_ACTION"
        static let confirm = "CONFIRM_ACTION"
        static let snooze = "SNOOZE_ACTION"
    }
    
    struct Category {
        static let alarm = "ALARM_NOTIFICATION"
    }
    
    private static var instance: Notifications?
    static var current: Notifications {
        get {
            if instance == nil {
                instance = Notifications()
            }
            return instance!
        }
    }
    
    private override init() {
        super.init()
        
        let openAction = UNNotificationAction(identifier: Action.open, title: "Open App", options: [.foreground])
        let confirmAction = UNNotificationAction(identifier: Action.confirm, title: "Confirm", options: [.destructive])
        let snoozeAction = UNNotificationAction(identifier: Action.snooze, title: "Snooze")
        let actions = [openAction, confirmAction, snoozeAction]
        
        let notificationCategory = UNNotificationCategory(identifier: Category.alarm, actions: actions, intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "%u alarms", options: .customDismissAction)
        notificationCenter.setNotificationCategories([notificationCategory])
        
        notificationCenter.delegate = self
    }

    func requestPermissions() {
        notificationCenter.getNotificationSettings { [unowned notificationCenter] settings in
            guard settings.authorizationStatus != .authorized else {
                return
            }
            
            notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in
                if !granted {
                    print("Application is not authorized to send notififcations")
                }
            }
        }
    }
    
    func scheduleNotification(for alarmId: UUID?) -> UUID? {
        // check whether alarm is present in storage
        guard let alarm = AlarmStorage.current.items.find(by: alarmId) else {
            return nil
        }

        // remove old alarm notification, if any
        unscheduleNotification(for: alarm.uuid)
        
        // check whether we can define notification properties using given alarm object
        guard let alarmName = alarm.name, let alarmDate = alarm.date else {
            return nil
        }
        
        // construct new notification request
        let content = UNMutableNotificationContent()
        content.body = alarmName
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = Category.alarm
        
        let notificationDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: alarmDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        
        let notificationReqId = UUID()
        let request = UNNotificationRequest(identifier: notificationReqId.uuidString,
                                            content: content, trigger: trigger)
        
        // try to schedule the notification
        requestPermissions()
        notificationCenter.add(request) { error in
            guard let error = error else {
                return
            }
            
            print("Unable to schedule notification. \(error.localizedDescription)")
        }
        
        // return ID of the created notification
        return notificationReqId
    }
    
    func unscheduleNotification(for alarmId: UUID?) {
        // return if no such alarm in storage
        guard let alarm = AlarmStorage.current.items.find(by: alarmId) else {
            return
        }
        
        // remove all associated notifications
        switch alarm.status {
        case .enabled(let notificationReqId) where notificationReqId != nil:
            let reqIdString = notificationReqId!.uuidString
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [reqIdString])
            //notificationCenter.removeDeliveredNotifications(withIdentifiers: [reqIdString])
        default:
            break
        }
    }
    
    func updateAlarmStatuses(completion: @escaping () -> Void) {
        notificationCenter.getDeliveredNotifications { notifications in
            // process all delivered notifications
            notifications.forEach { notification in
                // find alarm object for delivered notificaiton
                guard let alarm = AlarmStorage.current.items
                    .find(byNotificationId: notification.request.identifier) else {
                    return
                }
                
                alarm.status = .enabled(nil)
            }
            
            // save updated changes
            AlarmStorage.current.saveData()
            
            // trigger completion handler
            completion()
        }
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
            
        default:
            print("Unknown notification action selected")
        }
        
        completionHandler()
    }
}


