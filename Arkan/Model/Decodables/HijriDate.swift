//
//  HijriDate.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct HijriDate: Decodable {
    let date: String
    let format: String
    let day: String
    let weekday: HijriWeekday
    let month: HijriMonth
    let year: String
}
