//
//  MenuButton.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct MenuButton: View {
    
    @Binding var isToggled: Bool
    
    var body: some View {
        ZStack {
            Button {
                withAnimation { isToggled.toggle() }
            } label: {
                VStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: .infinity)
                            .frame(width: 15, height: 1)
                            .opacity(index == 1 && isToggled ? 0 : 1)
                            .offset(x: isToggled && index == 1 ? 2 : 0, y: isToggled && index == 1 ? 5 : 0)
                            .rotationEffect(.degrees(isToggled ? (42 * (index == 0 ? -1 : 1)) : 0), anchor: .trailing)
                            .scaleEffect(x: isToggled && index != 1 ? 1.25 : 1)
                            .offset(x: isToggled && index != 1 ? -2.5 : 0)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable
    @State var isToggled = false
    
    MenuButton(isToggled: $isToggled)
}
