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
        case matchNotFound
        case dataNotFound
    }
    
    static func getPrayerTimes(forDate date: Date = .now) async throws -> PrayerTimesInfo {
        let dailyPrayerTimesContext = try ModelContext(.init(for: SpecificDateArchivedPrayerTimes.self))
        
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
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
            return try await NetworkManager.getPrayerTimes(forDate: date, latitude: latitude, longitude: longitude)
        } catch {
            print(error.localizedDescription)
        }
        
        /// If we failed to download the prayer times from the API,
        /// We'll now check to see if we have a yearly backup that we can use to get the prayer times of the passed-in date
        if isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate: date) {
            /// We have a stored backup and the user is probably offline
            return try getPrayerTimesFromYearlyArchive(forDate: date)
        }
        
        return .mock
//        do {
//            /// The location fetcher will get and store user's coordinates in UserDefaults
//            try await LocationFetcher().updateUserLocation()
//
//            /// First we'll try to download Today's prayer times from the server
//            let prayerTimesInfoForToday = try await NetworkManager.getPrayerTimes(forDate: .now, latitude: latitude, longitude: longitude)
//            
//            /// Updating the app to display the newly downloaded prayer times
//            withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
//            
//            /// Checking if there's a yearly backup and downloading if there wasn't
//            if !isThereAPrayerTimesBackupForThisYear() {
//                /// This code is duplicated because I wanted the priority to be for downloading a fresh prayer times data from the api and leaving the yearly backup to be downloaded in the background after the user is able to see today's prayer times
//                try? await downloadPrayerTimesBackupForThisYear()
//            }
//            
//            /// This function will exit when we download the prayerTimes info for today regardless of a successful yearly backup download
//            return
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        do {
//            /// If for any reason the download of today's prayer times fail, we'll go into the archives to see if there's one stored previously
//            /// But first we need to make sure we have an archive for the current year
//            if !isThereAPrayerTimesBackupForThisYear() {
//                if latitude != 0 && longitude != 0 {
//                    /// If there's no archive, we'll just download a new one
//                    try await downloadPrayerTimesBackupForThisYear()
//                }
//            }
//            
//            /// Reaching this line means we have an archive and "theoretically" it shouldn't fail
//            prayerTimesInfoForToday = try PrayerTimesArchiveManager.getPrayerTimesForDate()
//        } catch {
//            /// Backup not found and couldn't be downloaded
//            print(error.localizedDescription)
//        }
    }
    
    static func isThereAYearlyPrayerTimesBackup(containingPrayerTimesForDate date: Date) -> Bool {
        let currentYear = Calendar.current.component(.year, from: date)
        
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
        guard let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)),
              let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()),
              archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return false }
        
        return true
    }
    
    static func downloadPrayerTimesBackupForThisYear() async throws {
//        let currentYear = Calendar.current.component(.year, from: .now)
//        
//        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: currentYear, latitude: latitude, longitude: longitude)
//        
//        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: currentYear, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
//        context.insert(gregorianYearPrayerTimes)
//        try? context.save()
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
        
        guard let currentYearArchivedBackup = archivedYearlyBackups.first(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { throw PrayerTimesArchiveError.matchNotFound }
        
        let currentYearPrayerTimesByMonths = try currentYearArchivedBackup.getPrayerTimesByMonths()
        guard let prayerTimesInfosForCurrentMonth = currentYearPrayerTimesByMonths[String(currentMonth)] else { throw PrayerTimesArchiveError.dataNotFound }
        
        return prayerTimesInfosForCurrentMonth[currentDay]
    }
}
