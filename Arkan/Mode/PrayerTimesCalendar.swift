//
//  PrayerTimesCalendar.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct PrayerTimesCalendar: Decodable {
    let data: [String: [PrayerDay]]
}

struct PrayerDay: Decodable {
    let timings: Timings
}

struct Timings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
