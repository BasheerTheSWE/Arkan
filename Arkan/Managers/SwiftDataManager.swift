//
//  SwiftDataManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    let container: ModelContainer
    
    var context: ModelContext {
        ModelContext(container)
    }
    
    init() {
        let schema = Schema([GregorianYearPrayerTimes.self, SpecificDateArchivedPrayerTimes.self])
        let config = ModelConfiguration(groupContainer: .identifier("group.BasheerTheSWE.Arkan.PrayerTime"))
        
        self.container = try! ModelContainer(for: schema, configurations: config)
    }
//    static let shared = SwiftDataManager()
//    
//    let container: ModelContainer
//    
//    private init() {
//        let config = ModelConfiguration(
//            groupContainer: .identifier("group.BasheerTheSWE.Arkan.PrayerTime")
//        )
//        
//        self.container = try! ModelContainer(for: GregorianYearPrayerTimes.self, SpecificDateArchivedPrayerTimes.self, configurations: config)
//    }
//    
//    var context: ModelContext {
//        ModelContext(container)
//    }
}
