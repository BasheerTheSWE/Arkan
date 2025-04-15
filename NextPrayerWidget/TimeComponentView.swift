//
//  TimeComponentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 15/04/2025.
//

import SwiftUI

struct TimeComponentView: View {
    
    let time: String
    
    var body: some View {
        Text(time)
            .font(.custom("Impact", size: 50))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.1)
            .scaleEffect(y: 1.2)
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
