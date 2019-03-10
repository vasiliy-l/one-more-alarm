//
//  EditAlarmViewController.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class EditAlarmViewController: UIViewController {
    
    var alarmsViewModel: AlarmsViewModel!
    var alarmIndex: Int?

    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var propertiesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        propertiesTableView.register(TextEditTableCell.nib, forCellReuseIdentifier: TextEditTableCell.identifier)
        propertiesTableView.dataSource = self
        propertiesTableView.delegate = self
        
        refreshUI();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alarmsViewModel.discardChanges()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        alarmsViewModel.applyChanges();
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func saveSelectedTime() {
        alarmsViewModel.updateAlarm(for: alarmIndex, time: timePicker.date)
    }
    
    
    func refreshUI() {
        propertiesTableView.reloadData();
        
        if let date = alarmsViewModel.getAlarmTime(for: alarmIndex) {
            timePicker.setDate(date, animated: false)
        }
    }
}

extension EditAlarmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // name property
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextEditTableCell.identifier, for: indexPath) as? TextEditTableCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = "Name"
            cell.valueLabel.text = alarmsViewModel.getAlarmName(for: alarmIndex)
            
            return cell;
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:  // name  property
            let editNameAlert = UIAlertController(title: "Edit alarm name", message: nil, preferredStyle: .alert)
            editNameAlert.addTextField { textField in
                textField.text = self.alarmsViewModel.getAlarmName(for: self.alarmIndex)
            }
            
            let applyAction = UIAlertAction(title: "Apply", style: .default) { [unowned editNameAlert] action in
                if let textField = editNameAlert.textFields?[0],
                   let newAlarmName = textField.text,
                   newAlarmName.count > 0 { // update name only if not empty
                    self.alarmsViewModel.updateAlarm(for: self.alarmIndex, name: newAlarmName)
                }
                
                self.refreshUI();
            }
            editNameAlert.addAction(applyAction);
            
            present(editNameAlert, animated: true, completion: nil)
        default: // unknown property pressed
            return;
        }
    }
    
}
