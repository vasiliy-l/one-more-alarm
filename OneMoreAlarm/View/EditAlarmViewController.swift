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
    
    var selectedAlarmIndexToEdit: Int?
    private var actualAlarmIndex: Int!
    
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var propertiesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        propertiesTableViewModel = PropertiesTableViewModel(for: propertiesTableView)
        
        propertiesTableView.dataSource = self
        propertiesTableView.delegate = self
        
        // determine whether to work with selected alarm from previous screen or edit new alarm
        if let alarmIndex = selectedAlarmIndexToEdit {
            actualAlarmIndex = alarmIndex
        } else {
            actualAlarmIndex = alarmsViewModel.addAlarm()
        }
        
        refreshUI();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alarmsViewModel.discardChanges() // discard all unsaved changes
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        alarmsViewModel.applyChanges(); // save all changes
        navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Updates time value of current alarm during interaction with time picker
     */
    @IBAction func saveSelectedTime() {
        alarmsViewModel.updateAlarm(for: actualAlarmIndex, time: timePicker.date)
    }
    
    /**
     Sets correct state of UI controls according to current alarm characteristics
     */
    func refreshUI() {
        propertiesTableView.reloadData();
        
        if let date = alarmsViewModel.getAlarmTime(for: actualAlarmIndex) {
            timePicker.setDate(date, animated: false)
        }
    }
}

extension EditAlarmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propertiesTableViewModel.propertiesCount;
    }
    
    // Display properties in table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return propertiesTableViewModel.prepareCell(for: indexPath, using: alarmsViewModel, alarmId: actualAlarmIndex)
    }
    
    // Interact with user to update property value on selection from table
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        propertiesTableViewModel.performAction(for: indexPath, using: alarmsViewModel, on: self, alarmId: actualAlarmIndex)
    }
    
}
