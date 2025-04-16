//
//  NextPrayerTimeMediumWidget.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct NextPrayerTimeMediumWidget: View {
    
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
        
        self.systemImage = images[Prayer.allCases.firstIndex(of: entry.nextPrayer) ?? 0]
    }
    
    // MARK: - VIEW
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.25)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                HStack {
                    TimeComponentView(date: entry.nextPrayerDate, component: .hour)
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                        .offset(y: -4)
                    
                    TimeComponentView(date: entry.nextPrayerDate, component: .minute)
                }
                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(.label))
                        .frame(width: 4)
                    
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: -4) {
                            Text("Next Prayer")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .scaledToFit()
                                .minimumScaleFactor(0.1)
                            
                            Text(entry.nextPrayer.rawValue)
                                .font(.system(size: 75, weight: .heavy))
                                .lineLimit(1)
                                .scaledToFit()
                                .minimumScaleFactor(0.1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Time Left: ")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .fixedSize()
                            
                            Text(timerInterval: Date()...entry.nextPrayerDate, countsDown: true)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .top, .trailing], 2)
                    }
                    .padding(8)
                    .padding(.leading, 4)
                    .background(Color(.secondarySystemBackground))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
    }
}
