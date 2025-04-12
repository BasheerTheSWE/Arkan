//
//  DailyPrayerTimesWidget.swift
//  DailyPrayerTimesWidget
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct DailyPrayerTimesWidgetEntryView : View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Al Taif, SA")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.vertical, 8)
            
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        VStack {
                            Image(systemName: "sunset")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            
                            Text("4:43")
                                .font(.system(size: 18, weight: .bold))
                                .lineLimit(1)
                                .scaledToFit()
                                .minimumScaleFactor(0.2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
                Spacer()
                
                HStack {
                    Text("12, April 2025")
                        .font(.system(size: 10, design: .monospaced))
                    
                    Spacer()
                    
                    Text("13, Shawaal 1446")
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
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
