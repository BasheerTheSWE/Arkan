//
//  NextPrayerWidget.swift
//  NextPrayerWidget
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping @Sendable (NextPrayerTimeEntry) -> Void) {
        MainActor.assumeIsolated {
            if let entry = getTimelineEntriesFromArchive().first {
                completion(entry)
            } else {
                completion(NextPrayerTimeEntry(date: Date(), prayer: .fajr, timeString: "03:50"))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NextPrayerTimeEntry>) -> Void) {
        Task {
            let entries = await getTimelineEntries()
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }
    
    func placeholder(in context: Context) -> NextPrayerTimeEntry {
        MainActor.assumeIsolated {
            if let entry = getTimelineEntriesFromArchive().first {
                return entry
            }
            
            return NextPrayerTimeEntry(date: Date(), prayer: .fajr, timeString: "03:50")
        }
    }
    
    private func getTimelineEntries() async -> [NextPrayerTimeEntry] {
        let todayPrayerTimesEntries = await getTimelineEntriesForDate(date: .now)
        
        if !todayPrayerTimesEntries.isEmpty {
            return todayPrayerTimesEntries
        }
        
        /// Reaching here means this is the end of Today after Isha, and there're no more prayers to schedule
        /// So we'll schedule tomorrow's prayers
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let tomorrowPrayerTimesEntries = await getTimelineEntriesForDate(date: tomorrow)
        
        return tomorrowPrayerTimesEntries
    }
    
    @MainActor private func getTimelineEntriesFromArchive() -> [NextPrayerTimeEntry] {
        let todayPrayerTimesEntries = getTimelineEntriesFromArchiveForDate(date: .now)
        
        if !todayPrayerTimesEntries.isEmpty {
            return todayPrayerTimesEntries
        }
        
        /// Reaching here means this is the end of Today after Isha, and there're no more prayers to schedule
        /// So we'll schedule tomorrow's prayers
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let tomorrowPrayerTimesEntries = getTimelineEntriesFromArchiveForDate(date: tomorrow)
        
        return tomorrowPrayerTimesEntries
    }
    
    private func getTimelineEntriesForDate(date: Date) async -> [NextPrayerTimeEntry] {
        var result = [NextPrayerTimeEntry]()
        
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? await PrayerTimesManager.getOrDownloadPrayerTimesInfo(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        for prayer in Prayer.allCases {
            if let entryDate = prayerTimesInfo.getDateObject(forPrayer: prayer), entryDate > Date() {
                let entry = NextPrayerTimeEntry(date: entryDate, prayer: prayer, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true))
                result.append(entry)
            }
        }
        
        return result
    }
    
    @MainActor private func getTimelineEntriesFromArchiveForDate(date: Date) -> [NextPrayerTimeEntry] {
        var result = [NextPrayerTimeEntry]()
        
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? PrayerTimesManager.getPrayerTimesFromArchive(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        for prayer in Prayer.allCases {
            if let entryDate = prayerTimesInfo.getDateObject(forPrayer: prayer), entryDate > Date() {
                let entry = NextPrayerTimeEntry(date: entryDate, prayer: prayer, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true))
                result.append(entry)
            }
        }
        
        return result
    }
}

struct NextPrayerTimeEntry: TimelineEntry {
    let date: Date
    let prayer: Prayer
    let timeString: String
    
    let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
    let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
}

struct NextPrayerWidgetEntryView : View {
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            NextPrayerTimeSmallWidgetView(entry: entry)
            
        case .accessoryCircular:
            NextPrayerTimeCircularWidgetView(entry: entry)
            
        default:
            Text("Unsupported Size")
        }
    }
}

struct NextPrayerWidget: Widget {
    let kind: String = "NextPrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NextPrayerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Prayer Time")
        .description("Display the time for your next prayer")
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

#Preview(as: .systemSmall) {
    NextPrayerWidget()
} timeline: {
    NextPrayerTimeEntry(date: .now, prayer: .asr, timeString: "03:50")
    NextPrayerTimeEntry(date: .now, prayer: .asr, timeString: "3:50")
}
