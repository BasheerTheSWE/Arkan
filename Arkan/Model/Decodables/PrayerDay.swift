//
//  PrayerDay.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct PrayerDay: Decodable {
    let timings: Timings
    let date: DateInfo
    let meta: MetaData
}
