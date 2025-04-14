//
//  NextPrayerWidget.swift
//  NextPrayerWidget
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NextPrayerTimeEntry {
        MainActor.assumeIsolated {
            if let entry = getTimelineEntriesFromArchive(configuration: ConfigurationAppIntent()).first {
                return entry
            }
            
            return NextPrayerTimeEntry(date: Date(), configuration: ConfigurationAppIntent(), prayer: .fajr, timeString: "03:50")
        }
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> NextPrayerTimeEntry {
        if let entry = await getTimelineEntries(configuration: configuration).first {
            return entry
        }
        
        return NextPrayerTimeEntry(date: Date(), configuration: configuration, prayer: .fajr, timeString: "03:40")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<NextPrayerTimeEntry> {
        var entries: [NextPrayerTimeEntry] = []
        
        /// Getting the prayer times of Today
        entries = await getTimelineEntries(configuration: configuration)

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
    
    private func getTimelineEntries(configuration: ConfigurationAppIntent) async -> [NextPrayerTimeEntry] {
        let todayPrayerTimesEntries = await getTimelineEntriesForDate(date: .now, entryConfiguration: configuration)
        
        if !todayPrayerTimesEntries.isEmpty {
            return todayPrayerTimesEntries
        }
        
        /// Reaching here means this is the end of Today after Isha, and there're no more prayers to schedule
        /// So we'll schedule tomorrow's prayers
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let tomorrowPrayerTimesEntries = await getTimelineEntriesForDate(date: tomorrow, entryConfiguration: configuration)
        
        return tomorrowPrayerTimesEntries
    }
    
    @MainActor private func getTimelineEntriesFromArchive(configuration: ConfigurationAppIntent) -> [NextPrayerTimeEntry] {
        let todayPrayerTimesEntries = getTimelineEntriesFromArchiveForDate(date: .now, entryConfiguration: configuration)
        
        if !todayPrayerTimesEntries.isEmpty {
            return todayPrayerTimesEntries
        }
        
        /// Reaching here means this is the end of Today after Isha, and there're no more prayers to schedule
        /// So we'll schedule tomorrow's prayers
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let tomorrowPrayerTimesEntries = getTimelineEntriesFromArchiveForDate(date: tomorrow, entryConfiguration: configuration)
        
        return tomorrowPrayerTimesEntries
    }
    
    private func getTimelineEntriesForDate(date: Date, entryConfiguration: ConfigurationAppIntent) async -> [NextPrayerTimeEntry] {
        var result = [NextPrayerTimeEntry]()
        
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? await PrayerTimesManager.getOrDownloadPrayerTimesInfo(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        for prayer in Prayer.allCases {
            if let entryDate = prayerTimesInfo.getDateObject(forPrayer: prayer), entryDate > Date() {
                let entry = NextPrayerTimeEntry(date: entryDate, configuration: entryConfiguration, prayer: prayer, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true))
                result.append(entry)
            }
        }
        
        return result
    }
    
    @MainActor private func getTimelineEntriesFromArchiveForDate(date: Date, entryConfiguration: ConfigurationAppIntent) -> [NextPrayerTimeEntry] {
        var result = [NextPrayerTimeEntry]()
        
        var prayerTimesInfo = PrayerTimesInfo.getMockDataForSpecificDate(date: date)
        
        if let downloadedPrayerTimesInfo = try? PrayerTimesManager.getPrayerTimesFromArchive(forDate: date) {
            prayerTimesInfo = downloadedPrayerTimesInfo
        }
        
        for prayer in Prayer.allCases {
            if let entryDate = prayerTimesInfo.getDateObject(forPrayer: prayer), entryDate > Date() {
                let entry = NextPrayerTimeEntry(date: entryDate, configuration: entryConfiguration, prayer: prayer, timeString: prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true))
                result.append(entry)
            }
        }
        
        return result
    }
}

struct NextPrayerTimeEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
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

struct NextPrayerTimeCircularWidgetView: View {
    
    private let systemImage: String
    private let progress: CGFloat
    
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
        
        switch entry.prayer {
            
        case .fajr:
            self.progress = 1
            break
            
        case .dhuhr:
            self.progress = 0.75
            break
            
        case .asr:
            self.progress = 0.5
            break
            
        case .maghrib:
            self.progress = 0.25
            break
            
        case .isha:
            self.progress = 0
            break
        }
    }
    
    // MARK: - VIEW
    var body: some View {
        Text(entry.timeString)
            .font(.system(size: 24, weight: .bold))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.2)
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(.ultraThinMaterial, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .overlay {
                        Circle()
                            .trim(from: 0.0, to: 0.0001)
                            .stroke(Color(.label), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(45.0 - (270 * progress)))
                    }
            }
            .overlay(alignment: .bottom) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
    }
    
    func getHour() -> String {
        return String(entry.timeString.split(separator: ":")[0])
    }
    
    func getMinute() -> String {
        return String(entry.timeString.split(separator: ":")[1])
    }
}

struct NextPrayerWidget: Widget {
    let kind: String = "NextPrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            NextPrayerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    NextPrayerWidget()
} timeline: {
    NextPrayerTimeEntry(date: .now, configuration: .smiley, prayer: .asr, timeString: "03:50")
    NextPrayerTimeEntry(date: .now, configuration: .starEyes, prayer: .asr, timeString: "3:50")
}
