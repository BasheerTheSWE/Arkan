//
//  PlainIconButton.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI

struct PlainIconButton: View {
    
    let systemImage: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
        }
    }
}

#Preview {
    PlainIconButton(systemImage: "line.3.horizontal", action: {})
}
