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
    
    @State private var isPresentingDedication = false
    @State private var isPresentingSettings = false
    
    var body: some View {
        VStack {
            HStack {
                PlainIconButton(systemImage: "square.and.arrow.up") {
                    
                }
                
                Spacer()
                
                Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                    .font(.custom("ReemKufi", size: 18))
                    .foregroundStyle(.white)
                
                Spacer()
                
                MenuButton(isToggled: $isShowingMenuItems)
            }
            .foregroundStyle(.white)
            
            if isShowingMenuItems {
                VStack {
                    MenuOptionButton(title: "In Loving Memory") {
                        isPresentingDedication = true
                    }
                    .sheet(isPresented: $isPresentingDedication) {
                        DedicationView()
                    }
                    
                    MenuOptionButton(title: "Available Widgets") {
                        
                    }
                    
                    MenuOptionButton(title: "Settings") {
                        isPresentingSettings = true
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

private struct MenuOptionButton: View {
    
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.07))
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    MainHeaderView()
}
