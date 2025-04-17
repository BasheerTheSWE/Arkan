//
//  UDKey.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

enum UDKey: String {
    case prefers24HourTimeFormat // Bool
    case latitude // Double
    case longitude // Double
    case city // String
    case country // String
    case countryCode // String
    
    case isFajrNotificationDisabled // Bool
    case isDhuhrNotificationDisabled // Bool
    case isAsrNotificationDisabled // Bool
    case isMaghribNotificationDisabled // Bool
    case isIshaNotificationDisabled // Bool
    
    case selectedNotificationsSound // Int
}
