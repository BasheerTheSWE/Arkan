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
    
    func getDateObject(forPrayer prayer: Prayer) -> Date? {
        let dateString = date.gregorian.date
        let timeString = timings.getTime(for: prayer, use24HourFormat: true)
        
        let dateTimeString = "\(dateString) \(timeString)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.date(from: dateTimeString)
    }
    
    static let mock: PrayerTimesInfo = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let todayString = formatter.string(from: Date())
        
        return PrayerTimesInfo(
            timings: PrayerTimes(
                Fajr: "5:55",
                Sunrise: "6:02",
                Dhuhr: "12:19",
                Asr: "15:44",
                Maghrib: "18:37",
                Isha: "20:07"
            ),
            date: DateInfo(
                gregorian: GregorianDate(date: todayString, format: "dd-MM-yyyy"),
                hijri: HijriDate(
                    date: "14-10-1446",
                    format: "MM-DD-yyyy",
                    day: "14",
                    weekday: HijriWeekday(en: "Saturday", ar: "السبت"),
                    month: HijriMonth(number: 10, en: "Shawaal", ar: "شوال"),
                    year: "1446"
                )
            ),
            meta: MetaData(method: MetaDataMethod(name: "m"))
        )
    }()
    
    static func getMockDataForSpecificDate(date: Date) -> PrayerTimesInfo {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let todayString = formatter.string(from: date)
        
        return PrayerTimesInfo(
            timings: PrayerTimes(
                Fajr: "5:55",
                Sunrise: "6:02",
                Dhuhr: "12:19",
                Asr: "15:44",
                Maghrib: "18:37",
                Isha: "20:07"
            ),
            date: DateInfo(
                gregorian: GregorianDate(date: todayString, format: "dd-MM-yyyy"),
                hijri: HijriDate(
                    date: "14-10-1446",
                    format: "MM-DD-yyyy",
                    day: "14",
                    weekday: HijriWeekday(en: "Saturday", ar: "السبت"),
                    month: HijriMonth(number: 10, en: "Shawaal", ar: "شوال"),
                    year: "1446"
                )
            ),
            meta: MetaData(method: MetaDataMethod(name: "m"))
        )
    }
}
