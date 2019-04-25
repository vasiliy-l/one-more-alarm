//
//  ViewController.swift
//  OneMoreAlarm
//
//  Created by  William on 2/17/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var alarmsTableView: UITableView!
    @IBOutlet var clockView: ClockView!
    
    @IBOutlet weak var dayShiftPic: UIImageView!
    var selectedAlarmIndex: Int?

    var digitClockFace: ClockFace?




    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure table with alarms
        alarmsTableView.register(AlarmsTableCell.nib, forCellReuseIdentifier: AlarmsTableCell.identifier)
        alarmsTableView.dataSource = self
        alarmsTableView.delegate = self
        
        // Enable analog clock
        clockView.displayRealTime = true
        clockView.startClock()
        darkModeTheme()

    }
    // MARK: - Dark mode theme function
    func darkModeTheme() {

        if currentHour > nightModeTime {
            self.view.backgroundColor = bgNightModeColor
            dayShiftPic.image = UIImage(named: "night pic")
            alarmsTableView.backgroundColor = bgNightModeColor

        } else {
            self.view.backgroundColor = bgDayModeColor
            dayShiftPic.image = UIImage(named: "day pic")
            alarmsTableView.backgroundColor = bgDayModeColor
            
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateAlarmsData()
        refreshUI()
        //darkModeTheme()
    }
    
    func refreshUI() {
        alarmsTableView.reloadData()
    }
    
    func updateAlarmsData() {
        Notifications.current.processScheduledNotifications { (scheduledIdentifiers) in
            // update completed/incompleted notifications
            let existingAlarms = AlarmsStorage.current.alarmIndexes
            
            existingAlarms.forEach({ alarmId in
                var newStatus = AlarmStatus.Off
                
                if let notificationId = AlarmsStorage.current.getNotificationRequestId(for: alarmId) {
                    if scheduledIdentifiers.contains(notificationId) {
                        newStatus = .On
                    }
                }
                
                AlarmsStorage.current.updateAlarm(for: alarmId, status: newStatus)
            })
            AlarmsStorage.current.saveChanges()
            
            // then, update unresponsed notifications
            Notifications.current.processUnrespondedNotifications(task: { (unrespondedIdentifiers) in
                let existingAlarms = AlarmsStorage.current.alarmIndexes
                
                existingAlarms.forEach({ alarmId in
                    var newStatus: AlarmStatus?
                    
                    if let notificationId = AlarmsStorage.current.getNotificationRequestId(for: alarmId) {
                        if unrespondedIdentifiers.contains(notificationId) {
                            newStatus = .Skipped
                        }
                    }
                    
                    if let newStatus = newStatus {
                        AlarmsStorage.current.updateAlarm(for: alarmId, status: newStatus)
                    }
                })
                
                AlarmsStorage.current.saveChanges()
            })
        }
    }
    
    @IBAction func addAlarmButtonPressed(_ sender: UIButton) {
        selectedAlarmIndex = nil
        
        performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
        //let _ = appDelegate.notifications.scheduleNotification(withText: "Simple notification text", timeInterval: 5)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? EditAlarmViewController {
            destVC.selectedAlarmIndexToEdit = selectedAlarmIndex
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmsStorage.current.getAlarmsAmount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmsTableCell.identifier, for: indexPath) as? AlarmsTableCell else {
            return UITableViewCell()
        }

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        print("Test cell color")

        cell.alarmId = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlarmIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (_, indexPath) in
            // remove notification
            if let notificationRequestId = AlarmsStorage.current.getNotificationRequestId(for: indexPath.row) {
                Notifications.current.unscheduleNotification(withRequestId: notificationRequestId)
            }
            // and save changes
            AlarmsStorage.current.removeAlarm(at: indexPath.row)
            AlarmsStorage.current.saveChanges()
            
            // animate changes
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            self.selectedAlarmIndex = indexPath.row
            self.performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
        }
        
        return [editAction, removeAction]
    }

}
