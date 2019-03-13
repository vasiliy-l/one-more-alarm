//
//  ViewController.swift
//  OneMoreAlarm
//
//  Created by  William on 2/17/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var alarmsTableView: UITableView!
    @IBOutlet var clockView: ClockView!
    
    var alarmsViewModel: AlarmsViewModel!
    var selectedAlarmIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmsViewModel = AlarmsViewModel()
        
        // Configure table with alarms
        alarmsTableView.register(AlarmsTableCell.nib, forCellReuseIdentifier: AlarmsTableCell.identifier)
        alarmsTableView.dataSource = self
        alarmsTableView.delegate = self
        
        // Enable analog clock
        clockView.displayRealTime = true
        clockView.startClock()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshUI();
    }
    
    func refreshUI() {
        alarmsTableView.reloadData();
    }
    
    @IBAction func addAlarmButtonPressed(_ sender: UIButton) {
        selectedAlarmIndex = nil
        
        performSegue(withIdentifier: "goToAlarmDetailsView", sender: self)
        //let _ = appDelegate.notifications.scheduleNotification(withText: "Simple notification text", timeInterval: 5)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? EditAlarmViewController {
            destVC.alarmsViewModel = alarmsViewModel
            destVC.selectedAlarmIndexToEdit = selectedAlarmIndex
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmsViewModel.getAlarmsAmount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmsTableCell.identifier, for: indexPath) as? AlarmsTableCell else {
            return UITableViewCell()
        }
        
        cell.nameLabel.text = alarmsViewModel.getAlarmName(for: indexPath.row)
        cell.timeLabel.text = alarmsViewModel.getAlarmTimeString(for: indexPath.row)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlarmIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (_, indexPath) in
            
            if let notificationRequestId = self.alarmsViewModel.getAlarmNotificationRequestId(for: indexPath.row) {
                self.appDelegate.notifications.unscheduleNotification(withRequestId: notificationRequestId)
            }
            
            self.alarmsViewModel.removeAlarm(at: indexPath.row)
            self.alarmsViewModel.applyChanges()
            
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
