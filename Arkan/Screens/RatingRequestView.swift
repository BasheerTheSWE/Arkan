//
//  RatingRequestView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 17/04/2025.
//

import SwiftUI

struct RatingRequestView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(spacing: 32) {
                    Image(systemName: "moon.stars.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.black)
                        .frame(width: 75, height: 75)
                        .frame(width: 125, height: 125)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 34))
                    
                    VStack {
                        Text("Arkan")
                            .font(.largeTitle.bold())
                            .fontDesign(.rounded)
                        
                        Text("The best prayer-times reminder app")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("Help Us Grow")
                        .font(.largeTitle.bold())
                        .fontDesign(.rounded)
                    
                    Text("A quick review from you will help us grow and improve. If you're enjoying the app, please consider leaving one.")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                Spacer()
                
                LargeRatingRequestButton(title: "Rate us on the App Store") {
                    leaveReview()
                }
            }
            .padding()
            .background(.black.gradient)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PlainIconButton(systemImage: "xmark", size: 12) {
                        dismiss()
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .tint(.white)
    }
    
    private func leaveReview() {
        if let url = URL(string: "https://apps.apple.com/us/app/arkan-prayer-times/id6744721733?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

private struct LargeRatingRequestButton: View {
    
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(.black)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    RatingRequestView()
}
