//
//  NextPrayerTimeSmallWidget.swift
//  NextPrayerWidgetExtension
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeSmallWidget: View {
    
    private let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: entry.nextPrayer.getSystemImage())
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
