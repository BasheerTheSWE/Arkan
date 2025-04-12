//
//  PrayerTimeCell.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct PrayerTimeCell: View {
    
    @AppStorage(UDKey.prefers24HourTimeFormat.rawValue) private var prefers24HourTimeFormat = false
    
    private let systemImage: String
    
    private let prayer: Prayer
    private let prayerTimes: PrayerTimes
    
    private let isCompact: Bool
    
    // MARK: - INIT
    init(index: Int, prayerTimesInfo: PrayerTimesInfo, isCompact: Bool = false) {
        self.prayer = Prayer.allCases[index]
        self.prayerTimes = prayerTimesInfo.timings
        self.isCompact = isCompact
        
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
                
                Text(prayerTimes.getTime(for: prayer, use24HourFormat: true))
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
                
                Text(prayerTimes.getTime(for: prayer, use24HourFormat: prefers24HourTimeFormat))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                
                Button {
                    
                } label: {
                    Image(systemName: "speaker.wave.1.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color(.label))
                        .frame(width: 16, height: 16)
                }
                .padding(.leading)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 8))
        }
    }
}

//#Preview {
//    PrayerTimeCell(index: 0)
//}
