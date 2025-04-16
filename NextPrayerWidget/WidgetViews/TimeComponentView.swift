//
//  TimeComponentView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 15/04/2025.
//

import SwiftUI

struct TimeComponentView: View {
    
    enum TimeComponent { case hour, minute }
    
    let date: Date
    let component: TimeComponent
    
    var body: some View {
        Text(component == .hour ? getHour() : getMinute())
            .font(.custom("Impact", size: 50))
            .lineLimit(1)
            .scaledToFit()
            .minimumScaleFactor(0.1)
            .scaleEffect(y: 1.2)
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .overlay {
                Rectangle()
                    .fill(Color(.systemBackground))
                    .frame(height: 2)
            }
    }
    
    func getHour() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
    
    func getMinute() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}
