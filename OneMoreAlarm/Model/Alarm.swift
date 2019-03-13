//
//  Alarm.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

struct AlarmTime: Codable {
    var hour: Int;
    var minute: Int;
}

class Alarm: Codable {
    var name = "Alarm"
    var time: AlarmTime
    var notificationRequestId: String?
    
    init(hour: Int, minute: Int) {
        time = AlarmTime(hour: hour, minute: minute)
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
     Append collection with new alarm instance
     
     - returns: ID of created alarm object
     */
    func append() -> Int {
        let alarm =  Alarm(hour: 09, minute: 00)
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
