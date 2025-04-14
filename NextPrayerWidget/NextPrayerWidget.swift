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

struct NextPrayerTimeSmallWidgetView: View {
    
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
        
        self.systemImage = images[Prayer.allCases.firstIndex(of: entry.prayer) ?? 0]
    }
    
    // MARK: - VIEW
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.25)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                
                HStack(spacing: 4) {
                    TimeComponentView(time: getHour())
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                    
                    TimeComponentView(time: getMinute())
                }
                .frame(maxHeight: .infinity)
                
                HStack {
                    Text("Time Left: ")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .fixedSize()
                    
                    Text(timerInterval: Date()...entry.date, countsDown: true)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
    }
    
    func getHour() -> String {
        return String(entry.timeString.split(separator: ":")[0])
    }
    
    func getMinute() -> String {
        return String(entry.timeString.split(separator: ":")[1])
    }
}

private struct TimeComponentView: View {
    
    let time: String
    
    var body: some View {
        Text(time)
            .font(.custom("Impact", size: 50))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.1)
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .overlay {
                Rectangle()
                    .fill(Color(.systemBackground))
                    .frame(height: 2)
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
