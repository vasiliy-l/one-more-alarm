//
//  AlarmStatus.swift
//  OneMoreAlarm
//
//  Created by  William on 3/17/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation
import UIKit

enum AlarmStatus: Int, Codable {
    case On, Off, Skipped
    
    var SwitchColor: UIColor {
        get {
            switch self {
            case .Skipped:
                return .darkGray
            default:
                return .green
            }
        }
    }
}
