//
//  AlarmStatus.swift
//  OneMoreAlarm
//
//  Created by  William on 4/21/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation
import UIKit

enum AlarmStatus {
    case disabled
    case enabled(UUID?)
}

extension AlarmStatus: Codable {
    
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .disabled
        case 1:
            let notificationRequest = try container.decode(UUID.self, forKey: .associatedValue)
            self = .enabled(notificationRequest)
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .disabled:
            try container.encode(0, forKey: .rawValue)
        case .enabled(let notificationRequest):
            try container.encode(1, forKey: .rawValue)
            try container.encode(notificationRequest, forKey: .associatedValue)
        }
    }
}

extension AlarmStatus {
    
    func asSwitchColor() -> UIColor {
        switch self {
        case .enabled(let alarmId) where alarmId == nil:
            return .darkGray
        default:
            return .green
        }
    }
    
    func asBool() -> Bool {
        switch self {
        case .disabled:
            return false
        case .enabled(_):
            return true
        }
    }
}
