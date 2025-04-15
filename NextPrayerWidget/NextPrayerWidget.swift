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
            
            return NextPrayerTimeEntry(date: .now, nextPrayerDate: nextPrayerTime, prayer: .fajr)
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (NextPrayerTimeEntry) -> Void) {
        Task {
            if let entry = await getTimelineEntries().first {
                completion(entry)
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
            
        case .systemMedium:
            NextPrayerTimeMediumWidgetView(entry: entry)
            
        case .accessoryCircular:
            NextPrayerTimeCircularWidgetView(entry: entry)
            
        default:
            Text("Unsupported Size")
        }
    }
}

struct NextPrayerTimeMediumWidgetView: View {
    
    private let systemImage: String
    
    private let entry: Provider.Entry
    
    // MARK: - INIT
    init(entry: Provider.Entry) {
        self.entry = entry
        
        let images = [
            "sunrise",
            "sun.max",
            "cloud.sun",
            "sunset",
            "moon"
        ]
        
        self.systemImage = images[Prayer.allCases.firstIndex(of: entry.nextPrayer) ?? 0]
    }
    
    // MARK: - VIEW
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.25)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                HStack {
                    TimeComponentView(date: entry.nextPrayerDate, component: .hour)
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                        .offset(y: -4)
                    
                    TimeComponentView(date: entry.nextPrayerDate, component: .minute)
                }
                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(.label))
                        .frame(width: 4)
                    
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: -4) {
                            Text("Next Prayer")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .scaledToFit()
                                .minimumScaleFactor(0.1)
                            
                            Text(entry.nextPrayer.rawValue)
                                .font(.system(size: 75, weight: .heavy))
                                .lineLimit(1)
                                .scaledToFit()
                                .minimumScaleFactor(0.1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Time Left: ")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .fixedSize()
                            
                            Text(timerInterval: Date()...entry.nextPrayerDate, countsDown: true)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .top, .trailing], 2)
                    }
                    .padding(8)
                    .padding(.leading, 4)
                    .background(Color(.secondarySystemBackground))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
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
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

#Preview(as: .systemMedium) {
    NextPrayerWidget()
} timeline: {
    NextPrayerTimeEntry(date: .now, nextPrayerDate: Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now, prayer: .isha)
    NextPrayerTimeEntry(date: Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now, nextPrayerDate: Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now, prayer: .dhuhr)
}
