//
//  NextPrayerWidget.swift
//  NextPrayerWidget
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NextPrayerTimeEntry {
        MainActor.assumeIsolated {
            if let entry = getTimelineEntriesFromArchive().first {
                return entry
            }
            
            let nextPrayerTime = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: nextPrayerTime)
            
            return NextPrayerTimeEntry(date: Date(), nextPrayerTime: nextPrayerTime, prayer: .fajr, timeString: timeString)
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (NextPrayerTimeEntry) -> Void) {
        MainActor.assumeIsolated {
            if let entry = getTimelineEntriesFromArchive().first {
                completion(entry)
            } else {
                let nextPrayerTime = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: nextPrayerTime)
                
                completion(NextPrayerTimeEntry(date: Date(), nextPrayerTime: nextPrayerTime, prayer: .fajr, timeString: timeString))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NextPrayerTimeEntry>) -> Void) {
        Task {
            let entries = await getTimelineEntries()
            
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }
    
    // MARK: Helper functions
    private func getTimelineEntries() async -> [NextPrayerTimeEntry] {
        var entries = [NextPrayerTimeEntry]()
        
        let todayPrayerTimeObjects = await getPrayerTimeObjects(forDate: .now)
        let tomorrowPrayerTimeObjects = await getPrayerTimeObjects(forDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        
        let prayerTimeObjects = todayPrayerTimeObjects + tomorrowPrayerTimeObjects
        
        let currentDate = Date()
        
        for (index, prayerTimeObject) in prayerTimeObjects.enumerated() {
            /// Checking to see if the prayer has passed or not
            /// We don't want to schedule a future update for previous data!! Obviously!
            if prayerTimeObject.date > currentDate {
                /// Creating a timeline entry
                let nextPrayerTime = index < prayerTimeObjects.count - 1 ? prayerTimeObjects[index + 1].date : prayerTimeObject.date
                
                let entry = NextPrayerTimeEntry(date: prayerTimeObject.date, nextPrayerTime: nextPrayerTime, prayer: prayerTimeObject.prayer, timeString: prayerTimeObject.timeString)
                
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    @MainActor private func getTimelineEntriesFromArchive() -> [NextPrayerTimeEntry] {
        var entries = [NextPrayerTimeEntry]()
        
        let todayPrayerTimeObjects = getPrayerTimeObjectsFromArchive(forDate: .now)
        let tomorrowPrayerTimeObjects = getPrayerTimeObjectsFromArchive(forDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        
        let prayerTimeObjects = todayPrayerTimeObjects + tomorrowPrayerTimeObjects
        
        let currentDate = Date()
        
        for (index, prayerTimeObject) in prayerTimeObjects.enumerated() {
            /// Checking to see if the prayer has passed or not
            /// We don't want to schedule a future update for previous data!! Obviously!
            if prayerTimeObject.date > currentDate {
                /// Creating a timeline entry
                let nextPrayerTime = index < prayerTimeObjects.count - 1 ? prayerTimeObjects[index + 1].date : prayerTimeObject.date
                
                let entry = NextPrayerTimeEntry(date: prayerTimeObject.date, nextPrayerTime: nextPrayerTime, prayer: prayerTimeObject.prayer, timeString: prayerTimeObject.timeString)
                
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    private func getPrayerTimeObjects(forDate date: Date) async -> [PrayerTimeObject] {
        var prayerTimes = [PrayerTimeObject]()
        
        /// We'll download new prayer times from the server or use mock data if the download fails
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? await PrayerTimesManager.getOrDownloadPrayerTimesInfo(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        /// Getting the date of every prayer
        for prayer in Prayer.allCases {
            if let prayerDate = prayerTimesInfo.getDateObject(forPrayer: prayer) {
                prayerTimes.append(PrayerTimeObject(prayer: prayer, date: prayerDate, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true)))
            }
        }
        
        return prayerTimes
    }
    
    @MainActor private func getPrayerTimeObjectsFromArchive(forDate date: Date) -> [PrayerTimeObject] {
        var prayerTimes = [PrayerTimeObject]()
        
        /// We'll download new prayer times from the server or use mock data if the download fails
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? PrayerTimesManager.getPrayerTimesFromArchive(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        /// Getting the date of every prayer
        for prayer in Prayer.allCases {
            if let prayerDate = prayerTimesInfo.getDateObject(forPrayer: prayer) {
                prayerTimes.append(PrayerTimeObject(prayer: prayer, date: prayerDate, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true)))
            }
        }
        
        return prayerTimes
    }
    
    private struct PrayerTimeObject {
        let prayer: Prayer
        let date: Date
        let timeString: String
    }
}

struct NextPrayerTimeEntry: TimelineEntry {
    let date: Date
    let nextPrayerTime: Date
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
    NextPrayerTimeEntry(date: .now, nextPrayerTime: Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now, prayer: .fajr, timeString: "03:50")
    NextPrayerTimeEntry(date: Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now, nextPrayerTime: Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now, prayer: .dhuhr, timeString: "12:19")
}
