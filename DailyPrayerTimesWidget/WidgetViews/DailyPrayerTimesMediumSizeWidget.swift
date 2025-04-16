//
//  DailyPrayerTimesMediumSizeWidget.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct DailyPrayerTimesMediumSizeWidget: View {
    
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
