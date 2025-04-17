//
//  ContentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import SwiftData
import WidgetKit
import UserNotifications
import StoreKit

struct ContentView: View {
    
    @Environment(\.requestReview) private var requestReview
    
    @AppStorage(UDKey.appOpensCount.rawValue) private var appOpensCount = 0
    
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
                    VStack(spacing: 8) {
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
        .onAppear { checkForRatingRequest() }
        .task {
            await getPrayerTimesForToday()
            WidgetCenter.shared.reloadAllTimelines()
            
            try? await schedulePrayerTimesNotificationsForTheNext30Days()
        }
        .animation(.default, value: city)
        .animation(.default, value: countryCode)
    }
    
    private func getPrayerTimesForToday() async {
        /// First we'll try to get today's prayer times from archive because it's faster
        do {
            let prayerTimesInfoForToday = try PrayerTimesManager.getPrayerTimesFromArchive()
            
            withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
        } catch {
            print(error.localizedDescription)
        }
        
        /// Now we'll do a more accurate fetching for the prayer times
        /// By first updating the location
        /// Then checking the archives and downloading a new data if needed
        do {
            let prayerTimesInfoForToday = try await PrayerTimesManager.getOrDownloadPrayerTimesInfo(locationFetcher: locationFetcher)
            
            withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
        } catch {
            // TODO: HANDLE THIS ERROR
            print(error.localizedDescription)
        }
    }
    
    private func schedulePrayerTimesNotificationsForTheNext30Days() async throws {
        /// Updating the user's location if needed
        if latitude == .zero && longitude == .zero {
            try await locationFetcher.updateUserLocation()
        }
        
        try await NotificationsManager.schedulePrayerTimesNotificationsForTheNext12Days()
    }
    
    private func checkForRatingRequest() {
        appOpensCount += 1
        
        if [2, 10, 50, 100].contains(appOpensCount) {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
        .tint(Color(.label))
}

/*
 
 Current Prayer Widget
 Highlights the prayer in progress
 
 Prayer Progress Widget
 Shows how much time left until the next prayer
 
 Location + Times
 Includes city name + daily times
 
 Qibla Widget (future?)
 Adds value if Qibla direction is planned
 */
