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
            .padding(.bottom, 12)
            .foregroundStyle(.white)
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
        .background(Color(.secondarySystemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
