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
                            .frame(width: isToggled ? 14.3 : 15, height: 1)
                            .opacity(index == 1 && isToggled ? 0 : 1)
                            .rotationEffect(.degrees(isToggled ? (45 * (index == 0 ? -1 : 1)) : 0), anchor: .trailing)
                            .offset(y: isToggled && index == 1 ? 5 : 0)
                    }
                }
                .offset(x: isToggled ? -2 : 0)
            }
        }
    }
}

#Preview {
    @Previewable
    @State var isToggled = false
    
    MenuButton(isToggled: $isToggled)
}
