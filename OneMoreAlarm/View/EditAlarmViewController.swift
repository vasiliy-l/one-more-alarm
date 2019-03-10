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
    var propertiesTableViewModel: PropertiesTableViewModel!
    var alarmIndex: Int?

    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var propertiesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        propertiesTableViewModel = PropertiesTableViewModel(for: propertiesTableView)
       
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
        return propertiesTableViewModel.propertiesCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return propertiesTableViewModel.prepareCell(for: indexPath, using: alarmsViewModel, alarmIndex: alarmIndex)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        propertiesTableViewModel.performAction(for: indexPath, using: alarmsViewModel, on: self, alarmIndex: alarmIndex)
    }
    
}
