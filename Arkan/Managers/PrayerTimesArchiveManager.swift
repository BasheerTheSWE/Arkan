//
//  PrayerTimesArchiveManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

class PrayerTimesArchiveManager {
    
    enum PrayerTimesError: Error {
        case prayerTimesNotFound
    }
    
    static func getPrayerTimesForToday(from archivedYearlyPrayerTimes: [GregorianYearPrayerTimes]) async throws -> PrayerTimesInfo {
        let todaysDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: .now)
        let currentYear = todaysDateComponents.year ?? 0
        let currentMonth = todaysDateComponents.month ?? 0
        let currentDay = todaysDateComponents.day ?? 0
        
        /// Checking to see if the prayer times for today are archived
        if let currentYearPrayerTimesData = archivedYearlyPrayerTimes.first(where: { $0.year == currentYear }),
           let currentYearPrayerTimesByMonths = try? currentYearPrayerTimesData.getPrayerTimesByMonths(),
           let currentMonthPrayerTimes = currentYearPrayerTimesByMonths[String(currentMonth)] {
            
            return currentMonthPrayerTimes[currentDay]
        }
        
        /// This year's prayer times data is not downloaded
        /// We'll use the NetworkManager to download and store 'em
        let currentYearPrayerTimesByMonths = try await NetworkManager.getPrayerTimes(forYear: currentYear, city: "Taif", countryCode: "SA")
        
        if let currentMonthPrayerTimes = currentYearPrayerTimesByMonths[String(currentMonth)] {
            return currentMonthPrayerTimes[currentDay]
        }
        
        throw PrayerTimesError.prayerTimesNotFound
    }
}
