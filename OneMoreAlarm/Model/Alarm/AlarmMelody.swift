//
//  AlarmMelody.swift
//  OneMoreAlarm
//
//  Created by  William on 5/6/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation

enum AlarmMelody {
    case `default`
    
    func melodyName() -> String {
        switch self {
        case .default:
            return "Default"
        }
    }
}

extension AlarmMelody: Codable {
    
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
            self = .default
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .default:
            try container.encode(0, forKey: .rawValue)
        }
    }
}
