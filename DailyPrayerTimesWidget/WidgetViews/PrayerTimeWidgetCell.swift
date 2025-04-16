//
//  PrayerTimeWidgetCell.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 13/04/2025.
//

import SwiftUI

struct PrayerTimeWidgetCell: View {
        
    private let systemImage: String
    
    private let prayer: Prayer
    private let prayerTimes: PrayerTimes?
    
    private let isCompact: Bool
    private let prefers24HourTimeFormat: Bool
    
    // MARK: - INIT
    init(index: Int, prayerTimesInfo: PrayerTimesInfo?, isCompact: Bool = false, prefers24HourTimeFormat: Bool = false) {
        self.prayer = Prayer.allCases[index]
        self.prayerTimes = prayerTimesInfo?.timings
        self.isCompact = isCompact
        self.prefers24HourTimeFormat = prefers24HourTimeFormat
        
        let images = [
            "sunrise",
            "sun.max",
            "cloud.sun",
            "sunset",
            "moon"
        ]
        
        self.systemImage = images[index]
    }
    
    // MARK: - VIEW
    var body: some View {
        if isCompact {
            VStack {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
                Text(prayerTimes?.getTime(for: prayer, use24HourFormat: prefers24HourTimeFormat) ?? "N/A")
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(1)
                    .scaledToFit()
                    .minimumScaleFactor(0.2)
            }
        } else {
            HStack {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                
                Text(prayer.rawValue)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.leading)
                
                Spacer()
                
                if let prayerTimes = prayerTimes {
                    Text(prayerTimes.getTime(for: prayer, use24HourFormat: prefers24HourTimeFormat))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                        .transition(.blurReplace)
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 8))
        }
    }
}
