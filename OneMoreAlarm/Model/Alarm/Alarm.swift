//
//  Alarm.swift
//  OneMoreAlarm
//
//  Created by  William on 4/21/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

typealias AlarmID = UUID

class Alarm: Codable {
    private(set) var alarmId: AlarmID
    var name: String?
    var date: Date?
    var status: AlarmStatus
    
    init() {
        alarmId = AlarmID()
        name = "Alarm"
        status = .disabled
    }
}

extension Date {
    
    func toString() -> String {
        // prepare required formatters
        let timeFormatter = DateFormatter()
        timeFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.setLocalizedDateFormatFromTemplate("dd MMM, HH:mm")
        
        // calculate difference in days
        let calendar = Calendar.current
        let daysDifference = calendar.component(.day, from: self)
            - calendar.component(.day, from: Date())
        
        switch daysDifference {
        case 0:
            return timeFormatter.string(from: self)
        case 1:
            return "Tomorrow, \(timeFormatter.string(from: self))"
        default:
            return dateTimeFormatter.string(from: self)
        }
    }
    
    func correctTimeToFuture() -> Date {
        if self < Date() {
            return self.addingTimeInterval(60 * 60 * 24) // add one day
        }
        
        return self
    }
    
    func correctTimeToToday() -> Date {
        let returnDateComp = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        
        guard let hour = returnDateComp.hour,
            let minute = returnDateComp.minute,
            let second = returnDateComp.second else {
                return self;
        }
        
        guard let correctedDate = Calendar.current.date(bySettingHour: hour, minute: minute,
                                                        second: second, of: Date())  else {
            return self
        }
        
        return correctedDate
    }
}
