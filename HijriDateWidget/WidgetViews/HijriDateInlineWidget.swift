//
//  HijriDateInlineWidget.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct HijriDateInlineWidget: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text("\(entry.hijriDate.day), \(entry.hijriDate.month.en)")
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
}
