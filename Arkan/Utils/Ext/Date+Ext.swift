//
//  Date+Ext.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

extension Date {
    static func getTodaysFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d, MMMM yyyy"
        
        return formatter.string(from: Date())
    }
}
