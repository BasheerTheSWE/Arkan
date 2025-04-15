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
                let placeholderEntry = NextPrayerTimeEntry(date: .now, nextPrayerDate: entry.date, prayer: entry.prayer)
                return placeholderEntry
            }
            
            let nextPrayerTime = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
            
            return NextPrayerTimeEntry(date: .now, nextPrayerDate: nextPrayerTime, prayer: .fajr)
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (NextPrayerTimeEntry) -> Void) {
        Task {
            if let entry = await getTimelineEntries().first {
                let snapShotEntry = NextPrayerTimeEntry(date: .now, nextPrayerDate: entry.date, prayer: entry.prayer)
                completion(snapShotEntry)
            } else {
                let nextPrayerTime = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
                
                completion(NextPrayerTimeEntry(date: .now, nextPrayerDate: nextPrayerTime, prayer: .fajr))
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
        let currentDate = Date()
        var entries = [NextPrayerTimeEntry]()
        
        let todayPrayerTimeObjects = await getPrayerTimeObjects(forDate: .now)
        let tomorrowPrayerTimeObjects = await getPrayerTimeObjects(forDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        
        var prayerTimeObjects = todayPrayerTimeObjects + tomorrowPrayerTimeObjects
        
        guard !prayerTimeObjects.isEmpty else { return [] }
        
        prayerTimeObjects = prayerTimeObjects.filter { $0.date > currentDate }
        prayerTimeObjects.insert(PrayerTimeObject(prayer: prayerTimeObjects[0].previousPrayer, date: .now), at: 0)
        
        for (index, prayerTimeObject) in prayerTimeObjects.enumerated() {
            let nextPrayerDate = index < prayerTimeObjects.count - 1 ? prayerTimeObjects[index + 1].date : prayerTimeObject.date
            let entry = NextPrayerTimeEntry(date: prayerTimeObject.date, nextPrayerDate: nextPrayerDate, prayer: prayerTimeObject.prayer)
            
            entries.append(entry)
        }
        
        return entries
    }
    
    @MainActor private func getTimelineEntriesFromArchive() -> [NextPrayerTimeEntry] {
        let currentDate = Date()
        var entries = [NextPrayerTimeEntry]()
        
        let todayPrayerTimeObjects = getPrayerTimeObjectsFromArchive(forDate: .now)
        let tomorrowPrayerTimeObjects = getPrayerTimeObjectsFromArchive(forDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        
        var prayerTimeObjects = todayPrayerTimeObjects + tomorrowPrayerTimeObjects
        
        guard !prayerTimeObjects.isEmpty else { return [] }
        
        prayerTimeObjects = prayerTimeObjects.filter { $0.date > currentDate }
        prayerTimeObjects.insert(PrayerTimeObject(prayer: prayerTimeObjects[0].previousPrayer, date: .now), at: 0)
        
        for (index, prayerTimeObject) in prayerTimeObjects.enumerated() {
            let nextPrayerDate = index < prayerTimeObjects.count - 1 ? prayerTimeObjects[index + 1].date : prayerTimeObject.date
            let entry = NextPrayerTimeEntry(date: prayerTimeObject.date, nextPrayerDate: nextPrayerDate, prayer: prayerTimeObject.prayer)
            
            entries.append(entry)
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
                prayerTimes.append(PrayerTimeObject(prayer: prayer, date: prayerDate))
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
                prayerTimes.append(PrayerTimeObject(prayer: prayer, date: prayerDate))
            }
        }
        
        return prayerTimes
    }
    
    private struct PrayerTimeObject {
        let prayer: Prayer
        let date: Date
        
        var previousPrayer: Prayer {
            let index = Prayer.allCases.firstIndex(of: prayer) ?? 0
            return index == 0 ? .isha : Prayer.allCases[index - 1]
        }
    }
}

struct NextPrayerTimeEntry: TimelineEntry {
    let date: Date
    let nextPrayerDate: Date
    
    let prayer: Prayer
    var nextPrayer: Prayer {
        let index = Prayer.allCases.firstIndex(of: prayer) ?? 0
        return index == 4 ? .fajr : Prayer.allCases[index + 1]
    }
    
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
    NextPrayerTimeEntry(date: .now, nextPrayerDate: Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now, prayer: .fajr)
    NextPrayerTimeEntry(date: Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now, nextPrayerDate: Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now, prayer: .dhuhr)
}
