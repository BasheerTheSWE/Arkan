//
//  HijriDateWidget.swift
//  HijriDateWidget
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HijriDateEntry {
        MainActor.assumeIsolated {
            if let hijriDate = try? getHijriDateStringFromArchive(for: .now) {
                return HijriDateEntry(date: .now, hijriDate: hijriDate)
            }
            
            return .init(date: .now, hijriDate: .mock)
        }
    }

    func getSnapshot(in context: Context, completion: @escaping (HijriDateEntry) -> ()) {
        Task {
            if let hijriDate = try? await getHijriDate(for: .now) {
                let entry = HijriDateEntry(date: .now, hijriDate: hijriDate)
                completion(entry)
            }
            
            return completion(HijriDateEntry(date: .now, hijriDate: .mock))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [HijriDateEntry] = []
            let currentDate = Date()
            
            for offset in 0..<2 {
                let entryDate = Calendar.current.date(byAdding: .day, value: offset, to: currentDate)!
                
                if let hijriDate = try? await getHijriDate(for: entryDate) {
                    let entry = HijriDateEntry(date: entryDate, hijriDate: hijriDate)
                    entries.append(entry)
                }
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
    
    private func getHijriDate(for date: Date) async throws -> HijriDate {
        /// First we'll download the prayer times response from the API which'll contains the Hijri date as well
        return try await PrayerTimesManager.getOrDownloadPrayerTimesInfo(forDate: date).date.hijri
    }
    
    @MainActor private func getHijriDateStringFromArchive(for date: Date) throws -> HijriDate {
        return try PrayerTimesManager.getPrayerTimesFromArchive(forDate: date).date.hijri
    }
}

struct HijriDateEntry: TimelineEntry {
    let date: Date
    let hijriDate: HijriDate
}

struct HijriDateWidgetEntryView : View {
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            HijriDateAccessoryInlineWidgetView(entry: entry)
            
        default:
            Text("Unsupported Size")
        }
    }
}

struct HijriDateAccessoryInlineWidgetView: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text("\(entry.hijriDate.day), \(entry.hijriDate.month.en)")
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
}

struct HijriDateWidget: Widget {
    let kind: String = "HijriDateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HijriDateWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                HijriDateWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Hijri Date")
        .description("View today’s Hijri date at a glance")
    }
}

#Preview(as: .accessoryInline) {
    HijriDateWidget()
} timeline: {
    HijriDateEntry(date: .now, hijriDate: .mock)
}
