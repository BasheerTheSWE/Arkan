//
//  PrayerTimesInfo.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

struct PrayerTimesInfo: Decodable, Equatable {
    
    enum PrayerTimesInfoError: Error {
        case modelContextNotFound
        case failedToLoadArchivedData
        case networkError
    }
    
    let timings: PrayerTimes
    let date: DateInfo
    let meta: MetaData
    
    static func ==(lhs: PrayerTimesInfo, rhs: PrayerTimesInfo) -> Bool { lhs.date.gregorian.date == rhs.date.gregorian.date }
    
    func getFormattedHijriDate() -> String {
        return "\(date.hijri.day), \(date.hijri.month.en) \(date.hijri.year)"
    }
    
    static let mock = PrayerTimesInfo(timings: PrayerTimes(Fajr: "5:55", Sunrise: "6:02", Dhuhr: "12:19", Asr: "15:44", Maghrib: "18:37", Isha: "20:07"), date: DateInfo(gregorian: GregorianDate(date: "14-10-1446", format: "MM-DD-yyyy"), hijri: HijriDate(date: "14-10-1446", format: "MM-DD-yyyy", day: "14", weekday: HijriWeekday(en: "Saturday", ar: "السبت"), month: HijriMonth(number: 10, en: "Shawaal", ar: "شوال"), year: "1446")), meta: MetaData(method: MetaDataMethod(name: "m")))
}
