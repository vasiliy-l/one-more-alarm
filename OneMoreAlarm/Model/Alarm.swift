//
//  Alarm.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

class Alarm: Codable {
    var name: String
    var date: Date
    var status: AlarmStatus
    var notificationRequestId: String?
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
        self.status = .Off
    }
}

/**
 Collection of user alarms
 */
class AlarmsCollection: Codable {
    private var alarms: [Alarm] = [Alarm]()
    
    /**
     Amount of existing alarm objects
     */
    var count: Int {
        return alarms.count
    }
    
    
    func get(at index: Int) -> Alarm? {
        guard count >= index else {
            return nil
        }
        
        return alarms[index]
    }
    
    /**
     Append collection with new alarm instance set at 09:00
     
     - returns: ID of created alarm object or -1 if unable to add new alarm
     */
    func append() -> Int {
        let calendar = Calendar.current
        
        // try to set default time
        let dateWithSetTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
        guard let dateWithSetTimeUnwrapped = dateWithSetTime else {
            return -1
        }
        
        // then try to make the date after current time
        let alarmDate = dateWithSetTimeUnwrapped < Date()
            ? calendar.date(byAdding: .day, value: 1, to: dateWithSetTimeUnwrapped)
            : dateWithSetTimeUnwrapped
        guard let alarmDateUnwrapped = alarmDate else {
            return -1
        }
        
        // add new alarm object and return its index
        let alarm =  Alarm(name: "Alarm", date: alarmDateUnwrapped)
        alarms.append(alarm)
        return alarms.count - 1
    }
    
    /**
     Removes specific alarm object
     
     - parameters:
        - at: ID of the alarm that needs to be removed from collection
     */
    func remove(at index: Int) {
        alarms.remove(at: index)
    }
    
    
}
