//
//  NextPrayerTimeSmallWidget.swift
//  NextPrayerWidgetExtension
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeSmallWidget: View {
    
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
            HStack {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                
                Text(entry.nextPrayer.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .scaledToFit()
                    .minimumScaleFactor(0.25)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    TimeComponentView(date: entry.nextPrayerDate, component: .hour)
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                        .offset(y: -4)
                    
                    TimeComponentView(date: entry.nextPrayerDate, component: .minute)
                }
                .frame(maxHeight: .infinity)
                
                HStack {
                    Text("Time Left: ")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .fixedSize()
                    
                    Text(timerInterval: Date()...entry.nextPrayerDate, countsDown: true)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 2)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
    }
}
