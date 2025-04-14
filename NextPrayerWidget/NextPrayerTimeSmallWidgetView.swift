//
//  NextPrayerTimeSmallWidgetView.swift
//  NextPrayerWidgetExtension
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeSmallWidgetView: View {
    
    private let systemImage: String
    
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
        
        self.systemImage = images[Prayer.allCases.firstIndex(of: entry.prayer) ?? 0]
    }
    
    // MARK: - VIEW
    var body: some View {
        VStack(spacing: 0) {
//            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
            Text(entry.prayer.rawValue + " Time")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.25)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                
                HStack(spacing: 4) {
                    TimeComponentView(time: getHour())
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                    
                    TimeComponentView(time: getMinute())
                }
                .frame(maxHeight: .infinity)
                
                HStack {
                    Text("Time Left: ")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .fixedSize()
                    
                    Text(timerInterval: Date()...entry.date, countsDown: true)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 4)
            }
            .padding([.leading, .bottom, .trailing])
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
    }
    
    func getHour() -> String {
        return String(entry.timeString.split(separator: ":")[0])
    }
    
    func getMinute() -> String {
        return String(entry.timeString.split(separator: ":")[1])
    }
}

private struct TimeComponentView: View {
    
    let time: String
    
    var body: some View {
        Text(time)
            .font(.custom("Impact", size: 50))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.1)
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .overlay {
                Rectangle()
                    .fill(Color(.systemBackground))
                    .frame(height: 2)
            }
    }
}
