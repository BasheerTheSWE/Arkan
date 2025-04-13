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
        if let prayerTimesInfo = try? PrayerTimesArchiveManager.getPrayerTimesForDate() {
            return PrayerTimesEntry(date: Date(), configuration: ConfigurationAppIntent(), prayerTimesInfo: prayerTimesInfo)
        }
        
        return PrayerTimesEntry(date: Date(), configuration: ConfigurationAppIntent(), prayerTimesInfo: .mock)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PrayerTimesEntry {
        if let prayerTimesInfo = await getPrayerTimesInfo(forDate: .now) {
            return PrayerTimesEntry(date: .now, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
        }
        
        return PrayerTimesEntry(date: Date(), configuration: configuration, prayerTimesInfo: .mock)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PrayerTimesEntry> {
        var entries: [PrayerTimesEntry] = []
        
        let currentDate = Date()
        
        for offset in 0..<2 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: offset * 6, to: currentDate)!
            
            if let prayerTimesInfo = await getPrayerTimesInfo(forDate: entryDate) {
                
                let entry = PrayerTimesEntry(date: entryDate, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
                
                entries.append(entry)
            } else { print("Failed to get the entry") }
        }
        
        if entries.isEmpty {
            print("Failed to get prayerTimes info")
            let entry = PrayerTimesEntry(date: .now, configuration: configuration, prayerTimesInfo: .mock)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }

    private func getPrayerTimesInfo(forDate date: Date) async -> PrayerTimesInfo? {
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        do {
            /// First we'll try to download Today's prayer times from the server
            let prayerTimesInfoForToday = try await NetworkManager.getPrayerTimes(forDate: date, latitude: latitude, longitude: longitude)
            
            /// Checking if there's a yearly backup and downloading if there wasn't
            if !isThereAPrayerTimesBackupForThisYear() {
                /// This code is duplicated because I wanted the priority to be for downloading a fresh prayer times data from the api and leaving the yearly backup to be downloaded in the background after the user is able to see today's prayer times
                try? await downloadPrayerTimesBackupForYear(ofDate: date)
            }
            
            /// This function will exit when we download the prayerTimes info for today regardless of a successful yearly backup download
            return prayerTimesInfoForToday
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            /// If for any reason the download of today's prayer times fail, we'll go into the archives to see if there's one stored previously
            /// But first we need to make sure we have an archive for the current year
            if !isThereAPrayerTimesBackupForThisYear() {
                if latitude != 0 && longitude != 0 {
                    /// If there's no archive, we'll just download a new one
                    try await downloadPrayerTimesBackupForYear(ofDate: date)
                }
            }
            
            /// Reaching this line means we have an archive and "theoretically" it shouldn't fail
            return try PrayerTimesArchiveManager.getPrayerTimesForDate()
        } catch {
            /// Backup not found and couldn't be downloaded
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func isThereAPrayerTimesBackupForThisYear() -> Bool {
        let currentYear = Calendar.current.component(.year, from: .now)
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue)
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue)
        
        guard let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)) else { return false }
        
        guard let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()) else { return false }
        
        guard archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return false }
        
        return true
    }
    
    /// Downloads a yearly backup of prayer times for offline usage and stores it in SwiftData.
    /// - Parameter date: Think about it bro! If it's Dec 31, the last day of the year and the timeline has an entry for tomorrow's prayer times --That's a new year and that's why we're passing the entry date and not just using`Date.now`. IQ+++
    private func downloadPrayerTimesBackupForYear(ofDate date: Date) async throws {
        let currentYear = Calendar.current.component(.year, from: date)
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        let city = UserDefaults.shared.string(forKey: UDKey.city.rawValue) ?? ""
        let countryCode = UserDefaults.shared.string(forKey: UDKey.countryCode.rawValue) ?? ""
        
        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
        
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: currentYear, latitude: latitude, longitude: longitude)
        
        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: currentYear, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
        context.insert(gregorianYearPrayerTimes)
        try? context.save()
    }
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
