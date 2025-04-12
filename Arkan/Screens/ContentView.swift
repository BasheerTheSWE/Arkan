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
            HStack {
                PlainIconButton(systemImage: "square.and.arrow.up.fill") {
                    
                }
                
                Spacer()
                
                Text("بسم الله الرحمن الرحيم")
                    .foregroundStyle(.white)
                
                Spacer()
                
                PlainIconButton(systemImage: "line.3.horizontal") {
                    
                }
            }
            .padding()
            .padding(.top, 32)
            .foregroundStyle(.white)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(.black)
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 16)
                    .offset(y: 8)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .background(Color(.secondarySystemGroupedBackground))
        .task {
            do {
                let times = try await NetworkManager.getPrayerTimes(forYear: 2025, city: "Taif", countryCode: "SA")
                
                print(times.count)
            } catch {
                print("Failed to get data")
            }
        }
    }
}

#Preview {
    ContentView()
}
