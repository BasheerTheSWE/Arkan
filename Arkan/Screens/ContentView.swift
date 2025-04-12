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
    
    @State private var prayerDay: PrayerDay?
    
    var body: some View {
        VStack {
            MainHeaderView()
            
            VStack {
                
                Spacer()
                
                VStack {
                    Text("Al Taif, SA")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Umm al-Qura University, Makkah")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("12, April 2025")
                        
                        Spacer()
                        
                        Text("13, Shawwal 1446")
                    }
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemFill).secondary)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(.bottom, 8)
                    
                    if let prayerDay = prayerDay {
                        ForEach(0..<5) { index in
                            PrayerTimeCell(index: index, prayerDay: prayerDay)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            getPrayerTimesForToday()
        }
    }
    
    private func getPrayerTimesForToday() {
        let todaysDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: .now)
        let currentYear = todaysDateComponents.year ?? 0
        let currentMonth = todaysDateComponents.month ?? 0
        let currentDay = todaysDateComponents.day ?? 0
        
        if let currentYearData = archivedYearlyPrayerTimes.first(where: { $0.year == currentYear }),
           let currentYearPrayerTimes = try? currentYearData.getPrayerTimesByMonths(),
           let currentMonthsPrayerTimes = currentYearPrayerTimes[String(currentMonth)] {
            prayerDay = currentMonthsPrayerTimes[currentDay]
            print("Found")
            
            return
        }
        
        /// This year's prayer times data is not downloaded
        /// We'll use the NetworkManager to download and store 'em
        Task {
            do {
                let currentYearPrayerTimes = try await NetworkManager.getPrayerTimes(forYear: currentYear, city: "Taif", countryCode: "SA")
                if let currentMonthPrayerTimes = currentYearPrayerTimes[String(currentMonth)] {
                    prayerDay = currentMonthPrayerTimes[currentDay]
                    
                    print("Downloaded")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
        .tint(Color(.label))
}
