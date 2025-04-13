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
        return SimpleEntry(date: Date(), configuration: configuration, prayerTimesInfo: .mock)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let sharedDefaults = UserDefaults(suiteName: "group.BasheerTheSWE.Arkan.PrayerTime")
        
        print("Testing")
        print(sharedDefaults?.string(forKey: "x"))
        
        let currentDate = Date()
        
        for offset in 0..<2 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: offset * 6, to: currentDate)!
            
//            print("Getting it")
//            if let prayerTimesInfo = await getPrayerTimesForEntryDate(entryDate: entryDate) {
//                print("Got the entry")
//                let city = UserDefaults.standard.string(forKey: UDKey.city.rawValue) ?? ""
//                let countryCode = UserDefaults.standard.string(forKey: UDKey.countryCode.rawValue) ?? ""
//                
//                let entry = SimpleEntry(date: entryDate, configuration: configuration, prayerTimesInfo: prayerTimesInfo, city: city, countryCode: countryCode)
//                
//                entries.append(entry)
//            } else { print("Failed to get the entry") }
            
            
            let entry = SimpleEntry(date: entryDate, configuration: configuration, prayerTimesInfo: .mock, city: "city", countryCode: "countryCode")
            
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
    
//    private func getPrayerTimesForEntryDate(entryDate: Date) async -> PrayerTimesInfo? {
//        do {
//            /// The location fetcher will get and store user's coordinates in UserDefaults
//            let (latitude, longitude) = try await LocationFetcher().updateUserLocation()
//            
//            /// First we'll try to download Today's prayer times from the server
//            if let prayerTimesInfoForToday = try? await NetworkManager.getPrayerTimes(forDate: entryDate, latitude: latitude, longitude: longitude) {
//                /// Checking if there's a yearly backup and downloading if there wasn't
//                if !isThereAPrayerTimesBackupForYear(ofDate: entryDate) {
//                    try? await downloadPrayerTimesBackupForYear(ofDate: entryDate, latitude: latitude, longitude: longitude)
//                }
//                
//                return prayerTimesInfoForToday
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        do {
//            if !isThereAPrayerTimesBackupForYear(ofDate: entryDate) {
//                let latitude = UserDefaults.standard.double(forKey: UDKey.latitude.rawValue)
//                let longitude = UserDefaults.standard.double(forKey: UDKey.longitude.rawValue)
//                
//                if latitude != 0 && longitude != 0 {
//                    /// If there's no archive, we'll just download a new one
//                    try await downloadPrayerTimesBackupForYear(ofDate: entryDate, latitude: latitude, longitude: longitude)
//                }
//            }
//            
//            return try PrayerTimesArchiveManager.getPrayerTimesForDate(date: entryDate)
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        return nil
//    }
//    
//    private func isThereAPrayerTimesBackupForYear(ofDate date: Date) -> Bool {
//        let currentYear = Calendar.current.component(.year, from: date)
//        let city = UserDefaults.standard.string(forKey: UDKey.city.rawValue)
//        let countryCode = UserDefaults.standard.string(forKey: UDKey.countryCode.rawValue)
//        
//        guard let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)) else { return false }
//        guard let archivedYearlyPrayerTimes = try? context.fetch(FetchDescriptor<GregorianYearPrayerTimes>()) else { return false }
//        
//        guard archivedYearlyPrayerTimes.contains(where: { $0.year == currentYear && $0.city == city && $0.countryCode == countryCode }) else { return false }
//        
//        return true
//    }
//    
//    private func downloadPrayerTimesBackupForYear(ofDate date: Date, latitude: Double, longitude: Double) async throws {
//        let currentYear = Calendar.current.component(.year, from: date)
//        let city = UserDefaults.standard.string(forKey: UDKey.city.rawValue) ?? ""
//        let countryCode = UserDefaults.standard.string(forKey: UDKey.countryCode.rawValue) ?? ""
//        
//        let context = try ModelContext(.init(for: GregorianYearPrayerTimes.self))
//        
//        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(forYear: currentYear, latitude: latitude, longitude: longitude)
//        
//        let gregorianYearPrayerTimes = GregorianYearPrayerTimes(year: currentYear, city: city, countryCode: countryCode, apiResponseData: apiResponseData)
//        context.insert(gregorianYearPrayerTimes)
//        try? context.save()
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let prayerTimesInfo: PrayerTimesInfo
    let city: String
    let countryCode: String
    let age: Int
    
    init(date: Date, configuration: ConfigurationAppIntent, prayerTimesInfo: PrayerTimesInfo, city: String = "", countryCode: String = "", age: Int = 0) {
        self.date = date
        self.configuration = configuration
        self.prayerTimesInfo = prayerTimesInfo
        self.city = city
        self.countryCode = countryCode
        self.age = age
    }
}

struct DailyPrayerTimesWidgetEntryView : View {
    
    @Environment(\.colorScheme) private var colorScheme
        
    var entry: Provider.Entry
    
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
