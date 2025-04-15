//
//  PrayerTimeCell.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct PrayerTimeCell: View {
    
    @AppStorage(UDKey.prefers24HourTimeFormat.rawValue) private var prefers24HourTimeFormat = false
    
    @AppStorage(UDKey.isFajrNotificationDisabled.rawValue) private var isFajrNotificationDisabled = false
    @AppStorage(UDKey.isDhuhrNotificationDisabled.rawValue) private var isDhuhrNotificationDisabled = false
    @AppStorage(UDKey.isAsrNotificationDisabled.rawValue) private var isAsrNotificationDisabled = false
    @AppStorage(UDKey.isMaghribNotificationDisabled.rawValue) private var isMaghribNotificationDisabled = false
    @AppStorage(UDKey.isIshaNotificationDisabled.rawValue) private var isIshaNotificationDisabled = false
    
    private let systemImage: String
    
    private let prayer: Prayer
    private let prayerTimes: PrayerTimes?
        
    // MARK: - INIT
    init(index: Int, prayerTimesInfo: PrayerTimesInfo?) {
        self.prayer = Prayer.allCases[index]
        self.prayerTimes = prayerTimesInfo?.timings
        
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
            
            Button {
                togglePrayerTimeNotification()
            } label: {
                Image(systemName: isPrayerNotificationDisabled() ? "speaker.slash.fill" : "speaker.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isPrayerNotificationDisabled() ? .secondary : Color(.label))
                    .frame(width: 16, height: 16)
            }
            .contentTransition(.symbolEffect)
            .padding(.leading)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private func togglePrayerTimeNotification() {
        switch prayer {
        case .fajr:
            withAnimation { isFajrNotificationDisabled.toggle() }
            break
            
        case .dhuhr:
            withAnimation { isDhuhrNotificationDisabled.toggle() }
            break
            
        case .asr:
            withAnimation { isAsrNotificationDisabled.toggle() }
            break
            
        case .maghrib:
            withAnimation { isMaghribNotificationDisabled.toggle() }
            break
            
        case .isha:
            withAnimation { isIshaNotificationDisabled.toggle() }
            break
        }
        
        Task { try? await NotificationsManager.schedulePrayerTimesNotificationsForTheNext12Days() }
    }
    
    private func isPrayerNotificationDisabled() -> Bool {
        switch prayer {
        case .fajr:
            return isFajrNotificationDisabled
            
        case .dhuhr:
            return isDhuhrNotificationDisabled
            
        case .asr:
            return isAsrNotificationDisabled
            
        case .maghrib:
            return isMaghribNotificationDisabled
            
        case .isha:
            return isIshaNotificationDisabled
        }
    }
}

//#Preview {
//    PrayerTimeCell(index: 0)
//}
