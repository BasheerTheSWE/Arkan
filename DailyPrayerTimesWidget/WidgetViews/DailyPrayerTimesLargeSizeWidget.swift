//
//  DailyPrayerTimesLargeSizeWidget.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct DailyPrayerTimesLargeSizeWidget: View {
    
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
