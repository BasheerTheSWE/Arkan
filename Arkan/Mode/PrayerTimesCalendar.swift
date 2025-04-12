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
    let date: DateInfo
}

struct Timings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct DateInfo: Decodable {
    let gregorian: GregorianDate
    let hijri: HijriDate
}

struct GregorianDate: Decodable {
    let date: String
    let format: String
}

struct HijriDate: Decodable {
    let date: String
    let format: String
    let day: String
    let weekday: HijriWeekday
    let month: HijriMonth
    let year: String
}

struct HijriWeekday: Decodable {
    let en: String
    let ar: String
}

struct HijriMonth: Decodable {
    let number: Int
    let en: String
    let ar: String
}
