//
//  MainHeaderView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct MainHeaderView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingMenuItems = false
    
    @State private var isPresentingSettings = false
    
    var body: some View {
        VStack {
            HStack {
                PlainIconButton(systemImage: "square.and.arrow.up") {
                    
                }
                
                Spacer()
                
                Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                    .foregroundStyle(.white)
                
                Spacer()
                
                MenuButton(isToggled: $isShowingMenuItems)
            }
            .foregroundStyle(.white)
            
            if isShowingMenuItems {
                VStack {
                    Button {
                        
                    } label: {
                        Text("About Us")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.07))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Contact Us")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.07))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    
                    Button {
                        isPresentingSettings = true
                    } label: {
                        Text("Settings")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.07))
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    .sheet(isPresented: $isPresentingSettings) {
                        SettingsView()
                    }
                }
                .padding(.top)
                .transition(.scale.combined(with: .opacity).combined(with: .blurReplace))
            }
        }
        .padding()
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .light ? .black : Color(.secondarySystemBackground))
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(Color(.systemGroupedBackground))
                .frame(height: 16)
                .offset(y: 8)
        }
    }
}

#Preview {
    MainHeaderView()
}
