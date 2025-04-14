//
//  PrayerTimesManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

class PrayerTimesManager {
    
    enum PrayerTimesArchiveError: Error {
        case dataNotFound
    }
    
    static func getPrayerTimes(forDate date: Date = .now) async throws -> PrayerTimesInfo {
        let dailyPrayerTimesContext = try ModelContext(.init(for: SpecificDateArchivedPrayerTimes.self))
        
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
        
        /// The location fetcher will get and store user's coordinates in UserDefaults
        try await LocationFetcher().updateUserLocation()
        
        /// First will check daily archiver to see if we have a stored prayer times info for this day
        do {
            let dailyArchivedPrayerTimes = try dailyPrayerTimesContext.fetch(FetchDescriptor<SpecificDateArchivedPrayerTimes>())
            
            if let archivedPrayerTimesData = dailyArchivedPrayerTimes.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.city == city && $0.countryCode == countryCode }) {
                /// BOOM! We have archived prayer times data for today
                return try archivedPrayerTimesData.getPrayerTimesInfo()
            }
        } catch {
            print(error.localizedDescription)
        }
        
        /// If we couldn't find stored data for the prayer times
        /// The next step is to try to download and store the prayer times for the passed-in date
        do {
            let prayerTimesAPIResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forDate: date, latitude: latitude, longitude: longitude)
            
            /// We have successfully downloaded the prayer times for the passed-in date from the API
            /// But before we return it, we should store in SwiftData
            let specificDateArchivedPrayerTimes = SpecificDateArchivedPrayerTimes(date: date, city: city, countryCode: countryCode, apiResponseData: prayerTimesAPIResponseData)
            dailyPrayerTimesContext.insert(specificDateArchivedPrayerTimes)
            try? dailyPrayerTimesContext.save()
            
            /// Since the download was successful, it means the user has stable internet connection
            /// So why don't we try to download a yearly backup if non exists
            if !isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate: date) {
                /// We want it to fail silently
                /// Note that this download will not be executed often, because it's a fucking yearly backup
                /// Meaning one backup will be good for an entire year ...
                try? await downloadPrayerTimesYearlyBackup(forDate: date)
            }
            
            /// Now we return the downloaded prayer times for the passed-in date :)
            /// 10/10 Execution
            /// ★★★★★ Performance
            return try specificDateArchivedPrayerTimes.getPrayerTimesInfo()
        } catch {
            print(error.localizedDescription)
        }
        
        /// If we failed to download the prayer times from the API,
        /// We'll now check to see if we have a yearly backup that we can use to get the prayer times of the passed-in date
        if isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate: date) {
            /// We have a stored backup and the user is probably offline
            return try getPrayerTimesFromYearlyArchive(forDate: date)
        }
        
        throw PrayerTimesArchiveError.dataNotFound
    }
    
    static func isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate date: Date) -> Bool {
        let year = Calendar.current.component(.year, from: date)
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
        guard let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)),
              let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()),
              archivedYearlyPrayerTimes.contains(where: { $0.year == year && $0.city == city && $0.countryCode == countryCode }) else { return false }
        
        return true
    }
    
    static func downloadPrayerTimesYearlyBackup(forDate date: Date) async throws {
        let year = Calendar.current.component(.year, from: date)
        
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
        
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: year, latitude: latitude, longitude: longitude)
        
        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
        
        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: year, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
        context.insert(gregorianYearPrayerTimes)
        try? context.save()
    }
    
    static func getPrayerTimesFromYearlyArchive(forDate date: Date = .now) throws -> PrayerTimesInfo {
        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
        let archivedYearlyBackups = try context.fetch(FetchDescriptor<GregorianYearPrayerTimes>())
        
        let todaysDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentYear = todaysDateComponents.year ?? 0
        let currentMonth = todaysDateComponents.month ?? 0
        let currentDay = todaysDateComponents.day ?? 0
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
        guard let currentYearArchivedBackup = archivedYearlyBackups.first(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { throw PrayerTimesArchiveError.dataNotFound }
        
        let currentYearPrayerTimesByMonths = try currentYearArchivedBackup.getPrayerTimesByMonths()
        guard let prayerTimesInfosForCurrentMonth = currentYearPrayerTimesByMonths[String(currentMonth)] else { throw PrayerTimesArchiveError.dataNotFound }
        
        return prayerTimesInfosForCurrentMonth[currentDay]
    }
}
