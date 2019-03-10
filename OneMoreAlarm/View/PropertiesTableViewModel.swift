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
        registedNibs()
    }
    
    private func registedNibs() {
         tableView.register(TextEditTableCell.nib, forCellReuseIdentifier: TextEditTableCell.identifier)
    }
    
    var propertiesCount: Int {
        return PropertyCell.count()
    }
    
    func prepareCell(for indexPath: IndexPath, using alarmsVM: AlarmsViewModel, alarmIndex: Int?) -> UITableViewCell {
        guard let property = PropertyCell.init(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch property {
        case .Name:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextEditTableCell.identifier, for: indexPath) as? TextEditTableCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = property.propertyName()
            cell.valueLabel.text = alarmsVM.getAlarmName(for: alarmIndex)
            
            return cell
        }
    }
    
    func performAction(for indexPath: IndexPath, using alarmsVM: AlarmsViewModel, on currentVC: UIViewController, alarmIndex: Int?) {
        
        guard let property = PropertyCell.init(rawValue: indexPath.row) else {
            return
        }
        
        switch property {
        case .Name:
            let editNameAlert = UIAlertController(
                title: "Edit alarm name",
                message: nil,
                preferredStyle: .alert)
            
            editNameAlert.addTextField { (textField) in
                let currentAlarmName = alarmsVM.getAlarmName(for: alarmIndex)
                textField.text = currentAlarmName
            }
            
            let applyAction = UIAlertAction(title: "Apply", style: .default) { [unowned editNameAlert] action in
                if let textField = editNameAlert.textFields?[0],
                   let newAlarmName = textField.text,
                   newAlarmName.count > 0 { // update name only if not empty
                    alarmsVM.updateAlarm(for: alarmIndex, name: newAlarmName)
                }
                
                self.tableView.reloadData()
            }
            editNameAlert.addAction(applyAction);
            
            currentVC.present(editNameAlert, animated: true, completion: nil)
        }
    }
}

enum PropertyCell: Int {
    case Name
    
    static var count = {
        return 1
    }
    
    static let propertyNames = [
        Name: "Name",
    ]
    
    func propertyName() -> String {
        if let propertyName = PropertyCell.propertyNames[self] {
            return propertyName
        } else {
            return ""
        }
    }
}
