//
//  AlarmsViewModel.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

fileprivate let kAlarmsCollection = "UserAlarms"

class AlarmsViewModel {
    let userDefaults = UserDefaults.standard;
    
    var alarmsColection: AlarmsCollection!
    var newAlarm: Alarm?
    
    init() {
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
    
    func getAlarmName(for index: Int) -> String {
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by given index
            return ""
        }
        return alarm.name
    }
    
    func getAlarmTimeString(for index: Int) -> String {
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by given index
            return ""
        }
        
        return String(format: "%02d:%02d", alarm.time.hour, alarm.time.minute)
    }
    
    func getAlarmTime(for index: Int) -> Date? {
        guard let alarm = alarmsColection.get(at: index) else {
            return nil
        }
        
        let alarmTime = alarm.time
        let date = Calendar.current.date(bySettingHour: alarmTime.hour, minute: alarmTime.minute, second: 0, of: Date())
        return date // TODO the same issue as above
    }
    
    func updateAlarm(for index: Int, name: String, time: Date) {
        updateAlarm(for: index, name: name)
        updateAlarm(for: index, time: time)
    }
    
    func updateAlarm(for index: Int, name: String) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        
        alarm.name = name
    }
    
    func updateAlarm(for index: Int, time: Date) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        alarm.time = AlarmTime(hour: hour, minute: minute)
    }
    
    func applyChanges() {
        let encodedAlarmsData = try? PropertyListEncoder().encode(alarmsColection)
        if (encodedAlarmsData != nil) {
            userDefaults.set(encodedAlarmsData, forKey: kAlarmsCollection)
        }
    }
    
    func discardChanges() {
        loadData()
    }
}
