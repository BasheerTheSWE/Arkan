//
//  LargeButton.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 17/04/2025.
//

import SwiftUI

struct LargeButton: View {
    
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(Color(.systemBackground))
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color(.label))
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    LargeButton(title: "Tap me", action: {})
        .padding()
}
