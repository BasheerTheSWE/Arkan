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
                    ForEach(0..<5) { _ in
                        HStack {
                            Image(systemName: "sunrise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            
                            Text("Fajr")
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
}
