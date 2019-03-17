//
//  AlarmsViewModel.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

fileprivate let kAlarmsCollection = "UserAlarms"

class AlarmsStorage {
    private(set) static var current: AlarmsStorage!
    
    let userDefaults = UserDefaults.standard;
    var alarmsColection: AlarmsCollection!
    
    static func prepareStorage() {
        AlarmsStorage.current = AlarmsStorage()
    }
    
    private init() {
        loadData()
    }
    
    /**
     Loads collection of alarms from User Defaults
     */
    func loadData() {
        if let storedAlarmsData = userDefaults.data(forKey: kAlarmsCollection),
            let storedAlarms = try? PropertyListDecoder().decode(AlarmsCollection.self, from: storedAlarmsData) {
            alarmsColection = storedAlarms
        } else {
            alarmsColection = AlarmsCollection()
        }
    }
    
    /**
     - returns: amount of existing alarms, including unsaved
     */
    func getAlarmsAmount() -> Int {
        return alarmsColection.count
    }
    
    /**
     Creates new alarm in collection
     
     - returns: index of created alarm
     */
    func addAlarm() -> Int {
        return alarmsColection.append()
    }
    
    func removeAlarm(at index: Int) {
        guard let _ = alarmsColection.get(at: index) else {
            return
        }
        
        alarmsColection.remove(at: index)
    }
    
    func getName(for index: Int) -> String {
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by given index
            return ""
        }
        return alarm.name
    }
    
    func getDateString(for index: Int) -> String {
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by given index
            return ""
        }
        
        // prepare required formatters
        let timeFormatter = DateFormatter()
        timeFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.setLocalizedDateFormatFromTemplate("dd MMM, HH:mm")
        
        // calculate difference in days
        let calendar = Calendar.current
        let daysDifference =
            calendar.component(.day, from: alarm.date)
                - calendar.component(.day, from: Date())
        
        switch daysDifference {
        case 0:
            return timeFormatter.string(from: alarm.date)
        case 1:
            return "Tomorrow, \(timeFormatter.string(from: alarm.date))"
        default:
            return dateTimeFormatter.string(from: alarm.date)
        }
    }
    
    func getDate(for index: Int) -> Date? {
        guard let alarm = alarmsColection.get(at: index) else {
            return nil
        }
        return alarm.date
    }
    
    func getNotificationRequestId(for index: Int) -> String? {
        return alarmsColection.get(at: index)?.notificationRequestId
    }
    
    func getStatus(for index: Int) -> AlarmStatus? {
        guard let alarm = alarmsColection.get(at: index) else {
            return nil
        }
        return alarm.status
    }
    
    func updateAlarm(for index: Int, name: String, date: Date) {
        updateAlarm(for: index, name: name)
        updateAlarm(for: index, date: date)
    }
    
    func updateAlarm(for index: Int, name: String) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        alarm.name = name
    }
    
    func updateAlarm(for index: Int, date: Date) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        
        // correct date to make sure that alarm will be set in future
        let calendar = Calendar.current
        let correctedDate = date < Date()
            ? calendar.date(byAdding: .day, value: 1, to: date)
            : date
        
        guard let correctedDateUnwrapped = correctedDate else {
            return
        }
        alarm.date = correctedDateUnwrapped
    }
    
    func updateAlarm(for index: Int, notificationRequestId: String?) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        alarm.notificationRequestId = notificationRequestId
    }
    
    func updateAlarm(for index: Int, status: AlarmStatus) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        alarm.status = status
    }
    
    func saveChanges() {
        let encodedAlarmsData = try? PropertyListEncoder().encode(alarmsColection)
        if (encodedAlarmsData != nil) {
            userDefaults.set(encodedAlarmsData, forKey: kAlarmsCollection)
        }
    }
    
    func discardChanges() {
        loadData()
    }
}
