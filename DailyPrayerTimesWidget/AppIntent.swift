//
//  AppIntent.swift
//  DailyPrayerTimesWidget
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Time Format" }
    static var description: IntentDescription { "Set your preferred time format." }
    
    // An example configurable parameter.
    @Parameter(title: "24 Hour Time Format", default: true)
    var prefers24HourTimeFormat: Bool
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
