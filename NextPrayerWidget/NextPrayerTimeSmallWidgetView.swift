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
            Text(entry.city.isEmpty || entry.countryCode.isEmpty ? "Location Unavailable" : "\(entry.city), \(entry.countryCode)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.25)
                .padding(.vertical, 8)
                .padding(.horizontal)
            
            VStack(alignment: .center) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                
                HStack(spacing: 4) {
                    NextPrayerTimeView(time: getHour(), maximumSize: 50)
                    
                    Text(":")
                        .font(.custom("Impact", size: 28))
                    
                    NextPrayerTimeView(time: getMinute(), maximumSize: 50)
                }
            }
            .padding()
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
