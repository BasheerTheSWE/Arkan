//
//  PlainIconButton.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct PlainIconButton: View {
    
    let systemImage: String
    let size: CGFloat
    let action: () -> ()
    
    // MARK: - INIT
    init(systemImage: String, size: CGFloat = 16, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.action = action
    }
    
    // MARK: - VIEW
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
            
        }
    }
}

#Preview {
    PlainIconButton(systemImage: "line.3.horizontal", action: {})
}
