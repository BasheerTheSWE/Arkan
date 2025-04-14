//
//  DailyPrayerTimesWidget.swift
//  DailyPrayerTimesWidget
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesEntry {
        MainActor.assumeIsolated {
            if let prayerTimesInfo = try? PrayerTimesManager.getPrayerTimesFromArchive() {
                return PrayerTimesEntry(date: Date(), configuration: ConfigurationAppIntent(), prayerTimesInfo: prayerTimesInfo)
            }
            
            return PrayerTimesEntry(date: Date(), configuration: ConfigurationAppIntent(), prayerTimesInfo: .mock)
        }
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PrayerTimesEntry {
        if let prayerTimesInfo = try? await PrayerTimesManager.getOrDownloadPrayerTimesInfo() {
            return PrayerTimesEntry(date: .now, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
        }
        
        return PrayerTimesEntry(date: Date(), configuration: configuration, prayerTimesInfo: .mock)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PrayerTimesEntry> {
        var entries: [PrayerTimesEntry] = []
        
        let currentDate = Date()
        
        for offset in 0..<2 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: offset * 6, to: currentDate)!
            
            if let prayerTimesInfo = try? await PrayerTimesManager.getOrDownloadPrayerTimesInfo(forDate: entryDate) {
                
                let entry = PrayerTimesEntry(date: entryDate, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
                
                entries.append(entry)
            }
        }
        
        if entries.isEmpty {
            let entry = PrayerTimesEntry(date: .now, configuration: configuration, prayerTimesInfo: .mock)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct PrayerTimesEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let prayerTimesInfo: PrayerTimesInfo
    
    let city: String = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
    let countryCode: String = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
}

// MARK: - WIDGET VIEW
struct DailyPrayerTimesWidgetEntryView : View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var widgetFamily
        
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            PrayerTimesMediumSizeWidget(entry: entry)
            
        case .systemLarge:
            PrayerTimesLargeSizeWidget(entry: entry)
            
        default:
            Text("Unsupported Size")
        }
    }
}

struct PrayerTimesMediumSizeWidget: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        PrayerTimeWidgetCell(index: index, prayerTimesInfo: entry.prayerTimesInfo, isCompact: true, prefers24HourTimeFormat: entry.configuration.prefers24HourTimeFormat)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
                Spacer()
                
                HStack {
                    Text(Date.getTodaysFormattedDate())
                        .font(.system(size: 10, design: .monospaced))
                    
                    Spacer()
                    
                    Text(entry.prayerTimesInfo.getFormattedHijriDate())
                        .font(.system(size: 10, design: .monospaced))
                }
                .padding(.horizontal)
                .frame(height: 24)
                .background(Color(.secondarySystemFill))
                .clipShape(.rect(cornerRadius: 4))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
        .background(Color(.secondarySystemBackground))
    }
}

struct PrayerTimesLargeSizeWidget: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            VStack {
                HStack {
                    Text(Date.getTodaysFormattedDate())
                        .font(.system(size: 10, design: .monospaced))
                    
                    Spacer()
                    
                    Text(entry.prayerTimesInfo.getFormattedHijriDate())
                        .font(.system(size: 10, design: .monospaced))
                }
                .padding(.horizontal)
                .frame(height: 24)
                .background(Color(.secondarySystemFill))
                .clipShape(.rect(cornerRadius: 4))
                .padding(.bottom, 8)
                
                VStack {
                    ForEach(0..<5) { index in
                        PrayerTimeWidgetCell(index: index, prayerTimesInfo: entry.prayerTimesInfo, prefers24HourTimeFormat: entry.configuration.prefers24HourTimeFormat)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
}

struct DailyPrayerTimesWidget: Widget {
    let kind: String = "DailyPrayerTimesWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DailyPrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Prayer Times")
        .description("Get accurate prayer times everyday")
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

extension View {
    @ViewBuilder func widgetBackground<T: View>(@ViewBuilder content: () -> T) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget, content: content)
        }else {
            background(content())
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.prefers24HourTimeFormat = false
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.prefers24HourTimeFormat = true
        return intent
    }
}

#Preview(as: .systemSmall) {
    DailyPrayerTimesWidget()
} timeline: {
    PrayerTimesEntry(date: .now, configuration: .smiley, prayerTimesInfo: .mock)
    PrayerTimesEntry(date: .now, configuration: .starEyes, prayerTimesInfo: .mock)
}
