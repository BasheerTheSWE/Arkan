//
//  PrayerTimesManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

@MainActor
class PrayerTimesManager {
    
    enum PrayerTimesArchiveError: Error {
        case dataNotFound
    }
    
    static let context = SwiftDataManager.shared.context
    
    static let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
    static let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
    
    static let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
    static let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
    
    // MARK: - PUBLIC
    static func getPrayerTimesFromArchive(forDate date: Date = .now) throws -> PrayerTimesInfo {
        /// First we'll try the daily archiver because it's more accurate
        do {
            return try getPrayerTimesInfoFromDailyArchiver(forDate: date)
        } catch {
            print(error.localizedDescription)
        }
        
        /// Next we'll try to get them from the yearly archiver
        return try getPrayerTimesFromYearlyArchive(forDate: date)
    }
    
    static func getOrDownloadPrayerTimesInfo(forDate date: Date = .now, locationFetcher: LocationFetcher? = nil) async throws -> PrayerTimesInfo {
        /// Before doing anything we'll clean the archives
        cleanUpArchives()
        
        /// The location fetcher will get and store user's coordinates in UserDefaults
        if locationFetcher != nil { try? await locationFetcher?.updateUserLocation() }
        
        /// First will check daily archiver to see if we have a stored prayer times info for this day
        do {
            return try getPrayerTimesInfoFromDailyArchiver(forDate: date)
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
            context.insert(specificDateArchivedPrayerTimes)
            try? context.save()
            
            /// Since the download was successful, it means the user has stable internet connection
            /// So why don't we try to download a yearly backup if non exists
            if !isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate: date) {
                /// We want it to fail silently
                /// Note that this download will not be executed often, because it's a fucking yearly backup
                /// Meaning one backup will be good for an entire year ...
                try? await downloadAndSavePrayerTimesYearlyBackup(forDate: date)
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
        return try getPrayerTimesFromYearlyArchive(forDate: date)
    }
    
    // MARK: - PRIVATE
    /// Cleans up the daily and yearly archives by removing stored prayer times for past years and days
    ///
    /// The user won't access prayer times of yesterday and it will just become clutter
    static private func cleanUpArchives() {
        guard let archivedDailyPrayerTimes = try? context.fetch(FetchDescriptor<SpecificDateArchivedPrayerTimes>()),
              let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()) else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Clean up daily archived prayer times (remove anything before today)
        for archived in archivedDailyPrayerTimes where calendar.compare(archived.date, to: today, toGranularity: .day) == .orderedAscending {
            context.delete(archived)
        }
        
        // Clean up yearly archived prayer times (remove any year before the current year)
        let currentYear = calendar.component(.year, from: today)
        
        for archived in archivedYearlyPrayerTimes where archived.year < currentYear {
            context.delete(archived)
        }
        
        // Save changes
        try? context.save()
    }
    
    static private func getPrayerTimesInfoFromDailyArchiver(forDate date: Date) throws -> PrayerTimesInfo {
        let dailyArchivedPrayerTimes = try context.fetch(FetchDescriptor<SpecificDateArchivedPrayerTimes>())
        
        if let archivedPrayerTimesData = dailyArchivedPrayerTimes.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.city == city && $0.countryCode == countryCode }) {
            /// BOOM! We have archived prayer times data for the passed-in date
            return try archivedPrayerTimesData.getPrayerTimesInfo()
        }
        
        throw PrayerTimesArchiveError.dataNotFound
    }
    
    static private func isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate date: Date) -> Bool {
        let year = Calendar.current.component(.year, from: date)
        
        guard let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()),
              archivedYearlyPrayerTimes.contains(where: { $0.year == year && $0.city == city && $0.countryCode == countryCode }) else { return false }
        
        return true
    }
    
    static private func downloadAndSavePrayerTimesYearlyBackup(forDate date: Date) async throws {
        let year = Calendar.current.component(.year, from: date)
        
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: year, latitude: latitude, longitude: longitude)
                
        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: year, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
        context.insert(gregorianYearPrayerTimes)
        try? context.save()
    }
    
    static private func getPrayerTimesFromYearlyArchive(forDate date: Date = .now) throws -> PrayerTimesInfo {
        guard isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate: date) else { throw PrayerTimesArchiveError.dataNotFound }
        
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
