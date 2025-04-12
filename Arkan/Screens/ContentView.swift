//
//  ContentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MainHeaderView()
            
            VStack {
                
                Spacer()
                
                VStack {
                    Text("Al Taif, SA")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Umm al-Qura University, Makkah")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("12, April 2025")
                        
                        Spacer()
                        
                        Text("13, Shawwal 1446")
                    }
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemFill).secondary)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(.bottom, 8)
                    
                    ForEach(0..<5) { index in
                        PrayerTimeCell(index: index)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
        .tint(Color(.label))
}
