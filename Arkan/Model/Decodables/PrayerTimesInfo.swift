//
//  PrayerTimesInfo.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

struct PrayerTimesInfo: Decodable {
    
    enum PrayerTimesInfoError: Error {
        case modelContextNotFound
        case failedToLoadArchivedData
    }
    
    let timings: PrayerTimes
    let date: DateInfo
    let meta: MetaData
    
    func getFormattedHijriDate() -> String {
        return "\(date.hijri.day), \(date.hijri.month.en) \(date.hijri.year)"
    }
    
    static let mock = PrayerTimesInfo(timings: PrayerTimes(Fajr: "4:44", Sunrise: "6:02", Dhuhr: "12:19", Asr: "15:44", Maghrib: "18:37", Isha: "20:07"), date: DateInfo(gregorian: GregorianDate(date: "14-10-1446", format: "MM-DD-yyyy"), hijri: HijriDate(date: "14-10-1446", format: "MM-DD-yyyy", day: "14", weekday: HijriWeekday(en: "Saturday", ar: "السبت"), month: HijriMonth(number: 10, en: "Shawaal", ar: "شوال"), year: "1446")), meta: MetaData(method: MetaDataMethod(name: "m")))
    
    @MainActor
    static func getInfoForToday() async throws -> PrayerTimesInfo {
        guard let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)) else { throw PrayerTimesInfoError.modelContextNotFound }
        guard let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()) else { throw PrayerTimesInfoError.failedToLoadArchivedData }
        
        return try await PrayerTimesManager.getPrayerTimesForToday(from: archivedYearlyPrayerTimes)
    }
}
