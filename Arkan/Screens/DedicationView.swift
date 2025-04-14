//
//  DedicationView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 13/04/2025.
//

import SwiftUI

struct DedicationView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let honoredLovedOnes = [
        "حمد داؤد خيرين",
        "الطيب حمد داؤد",
        "عبد اللطيف محمد سيد",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("صَدَقَةٌ جَارِيَةٌ")
                    .font(.custom("ReemKufi", size: 18))
                
                Text("لِأَرْوَاحٍ رَحَلَتْ وَ لَمْ تَكْتَفِي قُلُوْبُنَا مِنْ حُبِّهَا")
                    .font(.custom("ReemKufi", size: 14))
            }
            .foregroundStyle(.white)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .black)
            
            ScrollView {
                LazyVStack {
                    ForEach(honoredLovedOnes, id: \.self) { name in
                        HStack {
                            Text(name)
                                .font(.custom("Amiri-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .environment(\.layoutDirection, .leftToRight)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .clipShape(.rect(cornerRadius: 8))
            .padding(.top, -8)
            
            VStack(spacing: 8) {
                Text("أُدْعُ لَهَمْ بِالرَّحْمَةِ وَ المَغْفِرَةِ")
                    .font(.custom("ReemKufi", size: 14))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.top)
            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .black)
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(Color(.systemGroupedBackground))
                    .frame(height: 16)
                    .offset(y: -8)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DedicationView()
}
