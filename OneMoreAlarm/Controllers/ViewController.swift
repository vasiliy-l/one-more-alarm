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
    
    static let refreshUINotificationName = Notification.Name("refreshUIOnMainScreen")
    
    var selectedAlarmId: AlarmID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add observer for IU synchronization
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI(notification:)),
                                               name: ViewController.refreshUINotificationName,
                                               object: nil)
        
        // Configure table with alarms
        registerNibs()
        alarmsTableView.dataSource = self
        alarmsTableView.delegate = self
        
        // Enable analog clock
        clockView.displayRealTime = true
        clockView.startClock()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Notifications.current.updateAlarmStatusesForDeliveredNotifications {
            AlarmsStorage.current.items.updateStatusesForCompletedAlarms()
            AlarmsStorage.current.saveData()
            NotificationCenter.default.post(name: ViewController.refreshUINotificationName,
                                            object: nil)
        }
    }
    
    @objc func refreshUI(notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
            self.alarmsTableView.reloadData();
        }
    }
    
    @IBAction func addAlarmButtonPressed(_ sender: UIButton) {
        selectedAlarmId = nil
        performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? EditAlarmViewController {
            destVC.currentAlarmId = selectedAlarmId
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func registerNibs() {
        alarmsTableView.register(AlarmsTableCell.nib,
                                 forCellReuseIdentifier: AlarmsTableCell.identifier)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmsStorage.current.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmsTableCell.identifier, for: indexPath) as? AlarmsTableCell else {
            return UITableViewCell()
        }
        cell.alarmId = AlarmsStorage.current.items.find(by: indexPath)?.alarmId
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlarmId = AlarmsStorage.current.items.find(by: indexPath)?.alarmId
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (_, indexPath) in
            // remove notification
            let alarmId = AlarmsStorage.current.items.find(by: indexPath)?.alarmId
            Notifications.current.unscheduleNotification(for: alarmId)
            AlarmsStorage.current.items.remove(by: indexPath)
            
            // save changes
            AlarmsStorage.current.saveData()
            
            // animate changes
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            self.selectedAlarmId  = AlarmsStorage.current.items.find(by: indexPath)?.alarmId
            self.performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
        }
        
        return [editAction, removeAction]
    }

}
