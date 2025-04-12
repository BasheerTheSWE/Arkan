//
//  PrayerTimesInfo.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct PrayerTimesInfo: Decodable {
    let timings: PrayerTimes
    let date: DateInfo
    let meta: MetaData
    
    func getFormattedHijriDate() -> String {
        return "\(date.hijri.day), \(date.hijri.month.en) \(date.hijri.year)"
    }
}
