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
                .modelContainer(for: GregorianYearPrayerTimes.self)
        }
    }
}
