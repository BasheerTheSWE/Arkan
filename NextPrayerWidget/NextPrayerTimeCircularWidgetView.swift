//
//  NextPrayerTimeCircularWidgetView.swift
//  NextPrayerWidgetExtension
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeCircularWidgetView: View {
    
    private let systemImage: String
    private let progress: CGFloat
    
    private let entry: Provider.Entry
    
    // MARK: - INIT
    init(entry: Provider.Entry) {
        self.entry = entry
        
        let images = [
            "sunrise",
            "sun.max",
            "cloud.sun",
            "sunset",
            "moon"
        ]
        
        self.systemImage = images[Prayer.allCases.firstIndex(of: entry.nextPrayer) ?? 0]
        self.progress = 1 - (CGFloat(Prayer.allCases.firstIndex(of: entry.nextPrayer) ?? 0) / 4.0)
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
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(.regularMaterial, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .overlay {
                        Circle()
                            .trim(from: 0.0, to: 0.0001)
                            .stroke(Color(.label), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(45.0 - (270 * progress)))
                    }
            }
            .overlay(alignment: .bottom) {
                Image(systemName: systemImage)
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
