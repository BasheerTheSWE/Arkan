//
//  ArkanApp.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import SwiftData

@main
struct ArkanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color(.label))
                .defaultAppStorage(UserDefaults(suiteName: "group.BasheerTheSWE.Arkan.PrayerTime")!)
                .modelContainer(for: [GregorianYearPrayerTimes.self, SpecificDateArchivedPrayerTimes.self])
        }
    }
}
