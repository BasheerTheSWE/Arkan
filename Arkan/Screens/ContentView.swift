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
    
    @State private var prayerTimesInfoForToday: PrayerTimesInfo?
    
    var body: some View {
        VStack {
            MainHeaderView()
            
            VStack {
                
                Spacer()
                
                if let prayerTimesInfo = prayerTimesInfoForToday {
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
                            Text(Date.getTodaysFormattedDate())
                            
                            Spacer()
                            
                            Text(prayerTimesInfo.getFormattedHijriDate())
                        }
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.secondarySystemFill).secondary)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(.bottom, 8)
                        
                        
                        ForEach(0..<5) { index in
                            PrayerTimeCell(index: index, prayerTimesInfo: prayerTimesInfo)
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
            do {
                prayerTimesInfoForToday = try await PrayerTimesManager.getPrayerTimesForToday(from: archivedYearlyPrayerTimes)
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
