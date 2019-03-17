//
//  Bool+AlarmStatus.swift
//  OneMoreAlarm
//
//  Created by  William on 3/17/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

extension Bool {
    var asAlarmStatus: AlarmStatus {
        get {
            return self ? .On : .Off
        }
    }
}
