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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), prayerTimesInfo: .mock)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, prayerTimesInfo: .mock)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        
        for offset in 0..<2 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: offset * 6, to: currentDate)
            
            
        }
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            
//            /// Getting the prayerTimesInfo
//            var prayerTimesInfo: PrayerTimesInfo?
//            
//            if let archivedPrayerTimesInfo = try? await PrayerTimesInfo.getInfoForTodayFromArchive() {
//                prayerTimesInfo = archivedPrayerTimesInfo
//            } else if let downloadedPrayerTimesInfo = try? await PrayerTimesInfo.downloadPrayerTimesInfoForToday() {
//                prayerTimesInfo = downloadedPrayerTimesInfo
//            }
//            
//            guard let prayerTimesInfo = prayerTimesInfo else { continue }
//            
//            let entry = SimpleEntry(date: entryDate, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
//            entries.append(entry)
//        }
        
//        let entryDate = Calendar.current.startOfDay(for: .now)
        
        /// Getting the prayerTimesInfo
//        var prayerTimesInfo: PrayerTimesInfo?
        
//        if let archivedPrayerTimesInfo = try? await PrayerTimesInfo.getInfoForTodayFromArchive() {
//            prayerTimesInfo = archivedPrayerTimesInfo
//        } else if let downloadedPrayerTimesInfo = try? await PrayerTimesInfo.downloadPrayerTimesInfoForToday() {
//            prayerTimesInfo = downloadedPrayerTimesInfo
//        }
        
//        if let prayerTimesInfo = prayerTimesInfo {
//            let entry = SimpleEntry(date: entryDate, configuration: configuration, prayerTimesInfo: prayerTimesInfo)
//            entries.append(entry)
//        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
    
    private func getPrayerTimesForEntryDate(entryDate: Date) async -> PrayerTimesInfo? {
        do {
            let (latitude, longitude) = try await LocationFetcher().updateUserLocation()
            
            /// First we'll try to download Today's prayer times from the server
            if let prayerTimesInfoForToday = try? await NetworkManager.getPrayerTimes(forDate: entryDate, latitude: latitude, longitude: longitude) {
                /// Checking if there's a yearly backup or downloading if there wasn't
                /// The reason why I've put it here and two lines after is that I want the priority to be for downloading the accurate prayer times of today then downloading the yearly backup in the background
                try? await checkPrayerTimesBackupForThisYearOrDownloadIfNeeded(latitude: latitude, longitude: longitude)
                
                return prayerTimesInfoForToday
            }
            
            /// If for any reason the download fail, we'll into the archives for today's prayer times
            /// But first we need to make sure we have an archive for the current year
            try await checkPrayerTimesBackupForThisYearOrDownloadIfNeeded(latitude: latitude, longitude: longitude)
            
            /// Reaching this line means we have an archive and "theoretically" it shouldn't fail
            return try PrayerTimesArchiveManager.getPrayerTimesForDate(date: entryDate)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func checkPrayerTimesBackupForThisYearOrDownloadIfNeeded(latitude: Double, longitude: Double) async throws {
        let currentYear = Calendar.current.component(.year, from: .now)
        let city = UserDefaults.standard.string(forKey: UDKey.city.rawValue) ?? ""
        let countryCode = UserDefaults.standard.string(forKey: UDKey.countryCode.rawValue) ?? ""
        
        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
        let archivedYearlyPrayerTimes = try context.fetch(FetchDescriptor<GregorianYearPrayerTimes>())
        
        /// Return if the backup was found
        guard !archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return }
        
        /// If not ...
        /// Downloading a backup
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: currentYear, latitude: latitude, longitude: longitude)
        
        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: currentYear, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
        context.insert(gregorianYearPrayerTimes)
        try? context.save()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let prayerTimesInfo: PrayerTimesInfo
    let city: String = ""
    let countryCode: String = ""
}

struct DailyPrayerTimesWidgetEntryView : View {
    
    @Environment(\.colorScheme) private var colorScheme
        
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "Al Taif, SA")
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
                        PrayerTimeCell(index: index, prayerTimesInfo: entry.prayerTimesInfo, isCompact: true)
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
        
        
        //        VStack {
        //            Text("Al Taif, SA")
        //                .font(.system(size: 12, weight: .medium, design: .rounded))
        //
        //            VStack {
        //                Text("Time:")
        //                Text(entry.date, style: .time)
        //
        //                Text("Favorite Emoji:")
        //                Text(entry.configuration.favoriteEmoji)
        //            }
        //            .frame(maxWidth: .infinity, maxHeight: .infinity)
        //            .background(Color.black)
        //        }
    }
}

struct DailyPrayerTimesWidget: Widget {
    let kind: String = "DailyPrayerTimesWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DailyPrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
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
    DailyPrayerTimesWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, prayerTimesInfo: .mock)
    SimpleEntry(date: .now, configuration: .starEyes, prayerTimesInfo: .mock)
}
