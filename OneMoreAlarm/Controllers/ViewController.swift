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
    
    var selectedAlarmId: UUID?
    
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
            AlarmStorage.current.items.updateStatusesForCompletedAlarms()
            AlarmStorage.current.saveData()
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
        return AlarmStorage.current.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmsTableCell.identifier, for: indexPath) as? AlarmsTableCell else {
            return UITableViewCell()
        }
        cell.alarmId = AlarmStorage.current.items.find(by: indexPath)?.uuid
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlarmId = AlarmStorage.current.items.find(by: indexPath)?.uuid
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (_, indexPath) in
            // remove notification
            let alarmId = AlarmStorage.current.items.find(by: indexPath)?.uuid
            Notifications.current.unscheduleNotification(for: alarmId)
            AlarmStorage.current.items.remove(by: indexPath)
            
            // save changes
            AlarmStorage.current.saveData()
            
            // animate changes
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            self.selectedAlarmId  = AlarmStorage.current.items.find(by: indexPath)?.uuid
            self.performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
        }
        
        return [editAction, removeAction]
    }

}
