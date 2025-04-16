//
//  HijriDateCircularWidget.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct HijriDateCircularWidget: View {
    
    let entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "moon.stars.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            
            Text("\(entry.hijriDate.day), \(entry.hijriDate.month.en.prefix(2))")
                .font(.system(size: 28, weight: .medium))
                .lineLimit(1)
                .scaledToFit()
                .minimumScaleFactor(0.2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(.circle)
    }
}
