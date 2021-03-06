//
//  AlarmsStorage.swift
//  OneMoreAlarm
//
//  Created by  William on 4/21/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

fileprivate let kAlarmsCollection = "UserAlarms"

class AlarmsStorage {
    private let userDefaults = UserDefaults.standard;
    
    private var alarmsCollection: AlarmsCollection2!
    var items: [Alarm] {
        get {
            return alarmsCollection.items
        }
        set {
            alarmsCollection.items = newValue
        }
    }
    
    private static var instance: AlarmsStorage?
    static var current: AlarmsStorage {
        get {
            if instance == nil {
                instance = AlarmsStorage()
            }
            return instance!
        }
    }
    
    private init() {
        loadData()
    }
    
    /**
     Loads collection of alarms from User Defaults
     */
    func loadData() {
        if let storedAlarmsData = userDefaults.data(forKey: kAlarmsCollection),
            let storedAlarms = try? PropertyListDecoder().decode(AlarmsCollection2.self,
                                                                 from: storedAlarmsData) {
            alarmsCollection = storedAlarms
        } else {
            alarmsCollection = AlarmsCollection2()
        }
    }
    
    func saveData() {
        let encodedAlarmsData = try? PropertyListEncoder().encode(alarmsCollection)
        if (encodedAlarmsData != nil) {
            userDefaults.set(encodedAlarmsData, forKey: kAlarmsCollection)
        }
    }
}

class AlarmsCollection2: Codable {
    var items = [Alarm]()
}

extension Array where Element:Alarm {
    func find(by alarmId: AlarmID?) -> Alarm? {
        guard let alarmId = alarmId else {
            return nil
        }
        return first(where: {$0.alarmId == alarmId})
    }
    
    func find(by indexPath: IndexPath) -> Alarm? {
        // if no such item in the collection
        if count <= indexPath.row {
            return nil
        }

        return self[indexPath.row]
    }
    
    func find(byNotificationId: String) -> Alarm? {
        return first { alarm -> Bool in
            switch alarm.status {
            case .enabled(let notificationReqId) where notificationReqId != nil:
                return notificationReqId!.uuidString == byNotificationId
            default:
                return false
            }
        }
    }
    
    mutating func remove(by indexPath: IndexPath) {
        // if no such item in the collection
        guard count > indexPath.row else {
            return
        }
        
        remove(at: indexPath.row)
    }
    
    mutating func updateStatusesForCompletedAlarms() {
        forEach { alarm in
            switch alarm.status {
            case .enabled(let notificationReqId) where notificationReqId != nil:
                if let alarmDate = alarm.date, alarmDate < Date() {
                    Notifications.current.unscheduleNotification(for: alarm.alarmId)
                    alarm.status = .disabled
                }
            default:
                break;
            }
        }
    }
}
