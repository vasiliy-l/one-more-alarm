//
//  AlarmsTableCell.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class AlarmsTableCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    
    private var currentAlarmId: Int?
    
    var alarmId: Int? {
        get {
            return currentAlarmId
        }
        set {
            currentAlarmId = newValue
            
            guard let currentAlarmId = currentAlarmId else {
                return
            }
            
            let name = AlarmsStorage.current.getName(for: currentAlarmId)
            let timeStr = AlarmsStorage.current.getDateString(for: currentAlarmId)
            let status = AlarmsStorage.current.getStatus(for: currentAlarmId)
            
            nameLabel.text = name
            timeLabel.text = timeStr
            if let status = status {
                updateStausSwitch(with: status)
            }
        }
    }
    
    func updateStausSwitch(with status: AlarmStatus) {
        statusSwitch.onTintColor = status.SwitchColor
        switch status {
        case .Off:
            statusSwitch.isOn = false
        default:
            statusSwitch.isOn = true
        }
    }
    
    @IBAction func statusSwitchValueChanged(_ sender: UISwitch) {
        // update UI
        if sender.isOn && sender.onTintColor != AlarmStatus.On.SwitchColor {
            sender.onTintColor = AlarmStatus.On.SwitchColor
        }
        
        guard let currentAlarmId = currentAlarmId else {
            return
        }
        
        // update alarm notification
        var newNotification: String?
        if let oldNotification = AlarmsStorage.current.getNotificationRequestId(for: currentAlarmId) {
            Notifications.current.unscheduleNotification(withRequestId: oldNotification)
        }
        if sender.isOn {
            if let oldDate = AlarmsStorage.current.getDate(for: currentAlarmId) {
                AlarmsStorage.current.updateAlarm(for: currentAlarmId, date: oldDate)
            }
            
            if let date = AlarmsStorage.current.getDate(for: currentAlarmId) {
                let text = AlarmsStorage.current.getName(for: currentAlarmId)
                newNotification = Notifications.current.scheduleNotification(withText: text, date: date)
            }
        }
        
        // update stored settings
        AlarmsStorage.current.updateAlarm(for: currentAlarmId, status: sender.isOn.asAlarmStatus)
        AlarmsStorage.current.updateAlarm(for: currentAlarmId, notificationRequestId: newNotification)
        AlarmsStorage.current.saveChanges()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        timeLabel.text = nil
        updateStausSwitch(with: .Off)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
