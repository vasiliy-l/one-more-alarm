//
//  EditAlarmViewController.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class EditAlarmViewController: UIViewController {
    
    var propertiesTableViewModel: PropertiesTableViewModel!
    
    var currentAlarmId: AlarmID?
    
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var propertiesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        propertiesTableViewModel = PropertiesTableViewModel(for: propertiesTableView)
        
        propertiesTableView.dataSource = self
        propertiesTableView.delegate = self
        
        // create new alarm if required
        if currentAlarmId == nil {
            let newAlarm = Alarm()
            currentAlarmId = newAlarm.alarmId
            AlarmsStorage.current.items.append(newAlarm)
        }
        
        refreshUI();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AlarmsStorage.current.loadData() // discard all unsaved changes
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // save time explicitly, if the User did not interact with the time control
        saveSelectedTime()
        
        // correct alarm date to send notification in future
        if let alarmDate = AlarmsStorage.current.items.find(by: currentAlarmId)?.date {
            let updatedAlarmDate = alarmDate.correctTimeToFuture()
            AlarmsStorage.current.items.find(by: currentAlarmId)?.date = updatedAlarmDate
        }
        // register new notification
        let notificationReqId = Notifications.current.scheduleNotification(for: currentAlarmId)
        AlarmsStorage.current.items.find(by: currentAlarmId)?.status = .enabled(notificationReqId)
        
         // save changes and send notification about changes
        AlarmsStorage.current.saveData()
        //NotificationCenter.default.post(name: ViewController.refreshUINotificationName, object: nil)
        
        // return to previous screen
        navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Updates time value of current alarm during interaction with time picker
     */
    @IBAction func saveSelectedTime() {
        let date = timePicker.date.correctTimeToFuture()
        AlarmsStorage.current.items.find(by: currentAlarmId)?.date = date
    }
    
    /**
     Sets correct state of UI controls according to current alarm characteristics
     */
    func refreshUI() {
        #if DEBUG
          timePicker.minuteInterval = 1
        #endif
        
        if let alarmDate = AlarmsStorage.current.items.find(by: currentAlarmId)?.date {
            timePicker.setDate(alarmDate.correctTimeToToday(), animated: false)
        }
        
        propertiesTableView.reloadData();
    }
}

extension EditAlarmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propertiesTableViewModel.propertiesCount;
    }
    
    // Display properties in table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return propertiesTableViewModel.prepareCell(for: indexPath, alarmId: currentAlarmId)
    }
    
    // Interact with user to update property value on selection from table
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        propertiesTableViewModel.performAction(for: indexPath, on: self, alarmId: currentAlarmId)
    }
    
}
