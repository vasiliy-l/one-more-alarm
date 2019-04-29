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
    
    private var _alarmId: AlarmID?
    var alarmId: AlarmID?
    {
        get {
            return _alarmId
        }
        set {
            _alarmId = newValue
            
            // find required alarm object in storage by provided ID
            guard let foundAlarm = AlarmsStorage.current.items.find(by: newValue) else {
                return
            }
            
            // update UI
            nameLabel.text = foundAlarm.name
            timeLabel.text = foundAlarm.date?.toString()
            statusSwitch.onTintColor = foundAlarm.status.asSwitchColor()
            statusSwitch.isOn = foundAlarm.status.asBool()
        }
    }
    
    @IBAction func statusSwitchValueChanged(_ sender: UISwitch) {
        // update notifications
        switch sender.isOn {
        case true:
            // correct alarm date to send notification in future
            if let alarmDate = AlarmsStorage.current.items.find(by: alarmId)?.date {
                let updatedAlarmDate = alarmDate.correctTimeToFuture()
                AlarmsStorage.current.items.find(by: alarmId)?.date = updatedAlarmDate
            }
            
            // register new notification
            let notificationReqId = Notifications.current.scheduleNotification(for: alarmId)
            AlarmsStorage.current.items.find(by: alarmId)?.status = .enabled(notificationReqId)
        case false:
            Notifications.current.unscheduleNotification(for: alarmId)
            AlarmsStorage.current.items.find(by: alarmId)?.status = .disabled
        }
        
        // save updated alarms data
        AlarmsStorage.current.saveData()
        
        // update UI: switch appearance
        if let alarmStatus = AlarmsStorage.current.items.find(by: alarmId)?.status {
            if sender.onTintColor != alarmStatus.asSwitchColor() {
                sender.onTintColor = alarmStatus.asSwitchColor()
            }
        }
        // update UI: time label
        timeLabel.text = AlarmsStorage.current.items.find(by: alarmId)?.date?.toString()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        timeLabel.text = nil
        statusSwitch.isOn = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for selected state
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
