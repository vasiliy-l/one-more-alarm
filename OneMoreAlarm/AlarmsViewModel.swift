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
    
    func loadData() {
        if let storedAlarmsData = userDefaults.data(forKey: kAlarmsCollection),
           let storedAlarms = try? PropertyListDecoder().decode(AlarmsCollection.self, from: storedAlarmsData) {
            alarmsColection = storedAlarms
        } else {
            alarmsColection = AlarmsCollection()
        }
    }
    
    func getAlarmsAmount() -> Int {
        return alarmsColection.count
    }
    
    func getAlarmName(for index: Int?) -> String {
        guard let index = index else { // new alarm
            if newAlarm == nil {
                newAlarm = alarmsColection.newAlarmInstance();
            }
            return  newAlarm!.name
        }
        
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by explicit index
            return ""
        }
        return alarm.name
    }
    
    func getAlarmTimeString(for index: Int) -> String {
        guard let alarm = alarmsColection.get(at: index) else { // when no alarm by explicit index
            return ""
        }
        
        return String(format: "%02d:%02d", alarm.time.hour, alarm.time.minute)
    }
    
    func getAlarmTime(for index: Int?) -> Date? {
        guard let index = index else {
            if newAlarm == nil {
                newAlarm = alarmsColection.newAlarmInstance();
            }
            let alarmTime = newAlarm!.time
            let date = Calendar.current.date(bySettingHour: alarmTime.hour, minute: alarmTime.minute, second: 0, of: Date())
            return date // TODO for locales that uses Daylight Saving Times,
                        // some hours may not exist on the clock change days or they may
                        // occur twice. Needs to be checked for nil
        }
        
        guard let alarm = alarmsColection.get(at: index) else {
            return nil
        }
        
        let alarmTime = alarm.time
        let date = Calendar.current.date(bySettingHour: alarmTime.hour, minute: alarmTime.minute, second: 0, of: Date())
        return date // TODO the same issue as above
    }
    
    func updateAlarm(for index: Int, name: String, time: Date) {
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        alarm.name = name
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        alarm.time = AlarmTime(hour: hour, minute: minute)
    }
    
    func updateAlarm(for index: Int?, name: String) {
        guard let index = index else { // new alarm
            if newAlarm == nil {
                newAlarm = alarmsColection.newAlarmInstance();
            }
            return  newAlarm!.name = name
        }
        
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        
        alarm.name = name
    }
    
    func updateAlarm(for index: Int?, time: Date) {
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        
        guard let index = index else { // new alarm
            if newAlarm == nil {
                newAlarm = alarmsColection.newAlarmInstance();
            }
            return  newAlarm!.time = AlarmTime(hour: hour, minute: minute)
        }
        
        guard let alarm = alarmsColection.get(at: index) else {
            return
        }
        alarm.time = AlarmTime(hour: hour, minute: minute)
    }
    
    func removeAlarm(at index: Int?) {
        guard let index = index else {
            return
        }
        
        guard let _ = alarmsColection.get(at: index) else {
            return
        }
        
        alarmsColection.remove(at: index)
    }
    
    func applyChanges() {
        if let newAlarm = newAlarm {
            alarmsColection.add(newAlarm)
            
        }
        
        let encodedAlarmsData = try? PropertyListEncoder().encode(alarmsColection)
        if (encodedAlarmsData != nil) {
            userDefaults.set(encodedAlarmsData, forKey: kAlarmsCollection)
        }
        
        newAlarm = nil
    }
    
    func discardChanges() {
        loadData()
        newAlarm = nil
    }
}
