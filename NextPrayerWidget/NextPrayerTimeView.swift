//
//  NextPrayerTimeView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import SwiftUI

struct NextPrayerTimeView: View {
    
    let time: String
    let maximumSize: CGFloat
    
    var body: some View {
        Text(time)
            .font(.custom("Impact", size: maximumSize))
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
