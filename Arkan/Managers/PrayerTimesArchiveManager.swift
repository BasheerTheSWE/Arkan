//
//  PrayerTimesArchiveManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

class PrayerTimesArchiveManager {
    
    enum PrayerTimesArchiveError: Error {
        case matchNotFound
        case dataNotFound
    }
    
    static func getPrayerTimesForDate(date: Date = .now) throws -> PrayerTimesInfo {
        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
        let archivedYearlyBackups = try context.fetch(FetchDescriptor<GregorianYearPrayerTimes>())
        
        let todaysDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentYear = todaysDateComponents.year ?? 0
        let currentMonth = todaysDateComponents.month ?? 0
        let currentDay = todaysDateComponents.day ?? 0
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
        guard let currentYearArchivedBackup = archivedYearlyBackups.first(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { throw PrayerTimesArchiveError.matchNotFound }
        
        let currentYearPrayerTimesByMonths = try currentYearArchivedBackup.getPrayerTimesByMonths()
        guard let prayerTimesInfosForCurrentMonth = currentYearPrayerTimesByMonths[String(currentMonth)] else { throw PrayerTimesArchiveError.dataNotFound }
        
        return prayerTimesInfosForCurrentMonth[currentDay]
    }
}
