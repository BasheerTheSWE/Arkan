//
//  ContentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var archivedYearlyPrayerTimes: [GregorianYearPrayerTimes]
    
    @AppStorage(UDKey.countryCode.rawValue) private var countryCode = ""
    @AppStorage(UDKey.city.rawValue) private var city = ""
    
    @AppStorage(UDKey.latitude.rawValue) private var latitude = 0.0
    @AppStorage(UDKey.longitude.rawValue) private var longitude = 0.0
    
    @State private var prayerTimesInfoForToday: PrayerTimesInfo?
    @State private var locationFetcher = LocationFetcher()
    
    var body: some View {
        VStack {
            MainHeaderView()
            
            VStack {
                
                Spacer()
                
                if !city.isEmpty && !countryCode.isEmpty {
                    VStack {
                        Text("\(city), \(countryCode)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        
                        Text(prayerTimesInfoForToday?.meta.method.name ?? "Loading ...")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                    .transition(.move(edge: .bottom).combined(with: .blurReplace))
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        Text(Date.getTodaysFormattedDate())
                        
                        Spacer()
                        
                        Text(prayerTimesInfoForToday?.getFormattedHijriDate() ?? "Loading ...")
                    }
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemFill).secondary)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(.bottom, 8)
                    .contentTransition(.numericText())
                    
                    ForEach(0..<5) { index in
                        PrayerTimeCell(index: index, prayerTimesInfo: prayerTimesInfoForToday)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await getPrayerTimesForToday()
            WidgetCenter.shared.reloadAllTimelines()
        }
        .animation(.default, value: city)
        .animation(.default, value: countryCode)
    }
    
    private func getPrayerTimesForToday() async {
        do {
            /// The location fetcher will get and store user's coordinates in UserDefaults
            let (latitude, longitude) = try await locationFetcher.updateUserLocation()
            
            /// First we'll try to download Today's prayer times from the server
            if let prayerTimesInfoForToday = try? await NetworkManager.getPrayerTimes(forDate: .now, latitude: latitude, longitude: longitude) {
                /// Updating the app to display the newly downloaded prayer times
                withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
            }
            
            /// Checking if there's a yearly backup and downloading if there wasn't
            if !isThereAPrayerTimesBackupForThisYear() {
                /// This code is duplicated because I wanted the priority to be for downloading a fresh prayer times data from the api and leaving the yearly backup to be downloaded in the background after the user is able to see today's prayer times
                try? await downloadPrayerTimesBackupForThisYear(latitude: latitude, longitude: longitude)
            }
            
            return
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            /// If for any reason the download of today's prayer times fail, we'll go into the archives to see if there's one stored previously
            /// But first we need to make sure we have an archive for the current year
            if !isThereAPrayerTimesBackupForThisYear() {
                let latitude = UserDefaults.standard.double(forKey: UDKey.latitude.rawValue)
                let longitude = UserDefaults.standard.double(forKey: UDKey.longitude.rawValue)
                
                if latitude != 0 && longitude != 0 {
                    /// If there's no archive, we'll just download a new one
                    try await downloadPrayerTimesBackupForThisYear(latitude: latitude, longitude: longitude)
                }
            }
            
            /// Reaching this line means we have an archive and "theoretically" it shouldn't fail
            prayerTimesInfoForToday = try PrayerTimesArchiveManager.getPrayerTimesForDate()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func isThereAPrayerTimesBackupForThisYear() -> Bool {
        let currentYear = Calendar.current.component(.year, from: .now)
        
        guard archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return false }
        
        return true
    }
    
    private func downloadPrayerTimesBackupForThisYear(latitude: Double, longitude: Double) async throws {
        let currentYear = Calendar.current.component(.year, from: .now)
        
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: currentYear, latitude: latitude, longitude: longitude)
        
        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: currentYear, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
        context.insert(gregorianYearPrayerTimes)
        try? context.save()
    }
}

#Preview {
    ContentView()
        .tint(Color(.label))
}

/*
 Next Prayer Widget
 Shows only the next upcoming prayer
 
 Daily Prayer Times
 Shows all 5 daily times (Fajr to Isha)
 
 Current Prayer Widget
 Highlights the prayer in progress
 
 Prayer Progress Widget
 Shows how much time left until the next prayer
 
 Location + Times
 Includes city name + daily times
 
 Hijri Date Widget
 Shows Islamic date + prayer or time info
 
 Qibla Widget (future?)
 Adds value if Qibla direction is planned
 
 */
