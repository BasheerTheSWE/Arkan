//
//  NextPrayerTimeCircularWidget.swift
//  NextPrayerWidgetExtension
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeCircularWidget: View {
    
    private let entry: Provider.Entry
    private let progress: CGFloat
    
    // MARK: - INIT
    init(entry: Provider.Entry) {
        self.entry = entry
        self.progress = CGFloat(Prayer.allCases.firstIndex(of: entry.nextPrayer) ?? 0) / 4.0
    }
    
    // MARK: - VIEW
    var body: some View {
        Text(getTimeString())
            .font(.system(size: 24, weight: .bold))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.2)
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    Circle()
                        .trim(from: 0.0, to: 0.8)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(126))
                    
                    Circle()
                        .trim(from: 0.0, to: 0.001)
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(126.0 + (286 * progress)))
                }
                .compositingGroup()
                .luminanceToAlpha()
                .overlay {
                    Circle()
                        .trim(from: 0.0, to: 0.001)
                        .stroke(Color(.label), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(126.0 + (286 * progress)))
                }
            }
            .overlay(alignment: .bottom) {
                Image(systemName: entry.nextPrayer.getSystemImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
    }
    
    private func getTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current
        return formatter.string(from: entry.nextPrayerDate)
    }
}
