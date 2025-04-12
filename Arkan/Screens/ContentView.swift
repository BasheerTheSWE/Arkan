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
                Spacer()
                Spacer()
                
                VStack(spacing: 45) {
                    VStack {
                        Text("Al Taif, SA")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        Text("Umm al-Qura University, Makkah")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("12, April 2025")
                        
                        Spacer()
                        
                        Text("13, Shawwal 1446")
                    }
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .padding(.horizontal)
                }
                
                Divider()
                
                Spacer()
                
                VStack {
                    ForEach(0..<5) { index in
                        PrayerTimeCell(index: index)
                    }
                }
                
                Spacer()
                Spacer()
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
