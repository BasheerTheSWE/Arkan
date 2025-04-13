//
//  ContentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var archivedYearlyPrayerTimes: [GregorianYearPrayerTimes]
    
    @AppStorage(UDKey.countryCode.rawValue) private var countryCode = ""
    @AppStorage(UDKey.city.rawValue) private var city = ""
    
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
        .task { await getPrayerTimesForToday() }
        .animation(.default, value: city)
        .animation(.default, value: countryCode)
    }
    
    private func getPrayerTimesForToday() async {
        do {
            let (latitude, longitude) = try await locationFetcher.updateUserLocation()
            
            /// First we'll try to download Today's prayer times from the server
            if let prayerTimesInfoForToday = try? await NetworkManager.getPrayerTimes(forDate: .now, latitude: latitude, longitude: longitude) {
                withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
                return
            }
            
            /// If for any reason the download fail, we'll into the archives for today's prayer times
            /// But first we need to make sure we have an archive for the current year
            try await makeSureThereIsAPrayerTimesBackupForThisYear(latitude: latitude, longitude: longitude)
            
            /// Reaching this line means we have an archive and "theoretically" it shouldn't fail
            prayerTimesInfoForToday = try PrayerTimesArchiveManager.getPrayerTimesForToday()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func makeSureThereIsAPrayerTimesBackupForThisYear(latitude: Double, longitude: Double) async throws {
        let currentYear = Calendar.current.component(.year, from: .now)
        
        /// Return if the backup was found
        guard !archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return }
        
        /// If not ...
        /// Downloading a backup
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
