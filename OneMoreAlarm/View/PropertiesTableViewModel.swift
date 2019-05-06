//
//  PropertiesTableViewModel.swift
//  OneMoreAlarm
//
//  Created by  William on 3/10/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation
import UIKit

class PropertiesTableViewModel {
    
    let tableView: UITableView!
    
    init(for table: UITableView) {
        tableView = table
        registerNibs()
    }
    
    private func registerNibs() {
        tableView.register(TextEditTableCell.nib, forCellReuseIdentifier: TextEditTableCell.identifier)
    }
    
    /**
     Returns amount of existing properties
     */
    var propertiesCount: Int {
        return AlarmProperty.propertyNames.count
    }
    
    /**
     Prepares a cell object for properties table view by given index path
     
     - parameters:
         - indexPath: current index path of the table
         - alarmId: ID of the alarm which poperties should be used
     */
    func prepareCell(for indexPath: IndexPath, alarmId: AlarmID?) -> UITableViewCell {
        guard let property = AlarmProperty.init(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch property {
        case .Name:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextEditTableCell.identifier, for: indexPath) as? TextEditTableCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = property.propertyName()
            cell.valueLabel.text = AlarmsStorage.current.items.find(by: alarmId)?.name
            
            return cell
        case .Melody:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextEditTableCell.identifier, for: indexPath) as? TextEditTableCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = property.propertyName()
            cell.valueLabel.text = AlarmsStorage.current.items.find(by: alarmId)?.melody.melodyName()
            
            return cell
        }
    }
    
    /**
     Performs a particular action for poperty after the User selected a property cell
     
     - parameters:
         - indexPath: current index path of the table
         - currentVC: current ViewController object where properties table is placed
         - alarmId: ID of the alarm which poperties should be used
     */
    func performAction(for indexPath: IndexPath, on currentVC: UIViewController, alarmId: AlarmID?) {
        
        guard let property = AlarmProperty.init(rawValue: indexPath.row) else {
            return
        }
        
        switch property {
        case .Name:
            let editNameAlert = UIAlertController(
                title: "Edit alarm name",
                message: nil,
                preferredStyle: .alert)
            
            editNameAlert.addTextField { (textField) in
                let currentAlarmName = AlarmsStorage.current.items.find(by: alarmId)?.name
                textField.text = currentAlarmName
            }
            
            let applyAction = UIAlertAction(title: "Apply", style: .default) { [unowned editNameAlert] action in
                if let textField = editNameAlert.textFields?[0],
                    let newAlarmName = textField.text,
                    newAlarmName.count > 0 { // update name only if not empty
                        AlarmsStorage.current.items.find(by: alarmId)?.name = newAlarmName
                }
                
                self.tableView.reloadData()
            }
            editNameAlert.addAction(applyAction);
            
            currentVC.present(editNameAlert, animated: true, completion: nil)
        case .Melody:
            print("TODO")
        }
        
    }
}

enum AlarmProperty: Int {
    case Name
    case Melody
    
    static let propertyNames = [
        Name: "Name",
        Melody: "Melody",
        ]
    
    func propertyName() -> String {
        if let propertyName = AlarmProperty.propertyNames[self] {
            return propertyName
        } else {
            return ""
        }
    }
}
