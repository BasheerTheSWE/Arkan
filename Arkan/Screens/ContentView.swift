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
                            .animation(.default, value: city)
                            .animation(.default, value: countryCode)
                        
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
            locationFetcher.updateUserLocation { error, latitude, longitude in
                Task {
                    do {
                        let prayerTimesInfoForToday = try await PrayerTimesManager.getPrayerTimesForToday(from: archivedYearlyPrayerTimes)
                        
                        withAnimation { self.prayerTimesInfoForToday = prayerTimesInfoForToday }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
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
