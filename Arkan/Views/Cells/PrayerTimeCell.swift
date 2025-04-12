//
//  PrayerTimeCell.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct PrayerTimeCell: View {
    
    private let index: Int
    private let title: String
    private let systemImage: String
    
    // MARK: - INIT
    init(index: Int) {
        self.index = index
        
        switch index {
        case 0:
            /// Fajr prayer
            self.title = "Fajr"
            self.systemImage = "sunrise"
            
        case 1:
            /// Dhuhr prayer
            self.title = "Dhuhr"
            self.systemImage = "sun.max"
            
        case 2:
            /// Asr prayer
            self.title = "Asr"
            self.systemImage = "cloud.sun"
            
        case 3:
            /// Maghrib prayer
            self.title = "Maghrib"
            self.systemImage = "sunset"
            
        case 4:
            /// Isha prayer
            self.title = "Isha"
            self.systemImage = "moon"
            
        default:
            self.title = ""
            self.systemImage = ""
        }
    }
    
    // MARK: - VIEW
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.leading)
            
            Spacer()
            
            Text("4:43 AM")
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

#Preview {
    PrayerTimeCell(index: 0)
}
