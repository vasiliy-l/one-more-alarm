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
    
    init(hour: Int, minute: Int) {
        time = AlarmTime(hour: hour, minute: minute)
    }
}

class AlarmsCollection: Codable {
    var alarms: [Alarm] = [Alarm]()
    
    var count: Int {
        return alarms.count
    }
    
    func get(at index: Int) -> Alarm? {
        guard count >= index else {
            return nil
        }
        
        return alarms[index]
    }
    
    func add(_ alarm: Alarm) {
        alarms.append(alarm)
    }
    
    func remove(at: Int) {
        alarms.remove(at: at)
    }
    
    func newAlarmInstance() -> Alarm {
        return Alarm(hour: 09, minute: 00)
    }
}
