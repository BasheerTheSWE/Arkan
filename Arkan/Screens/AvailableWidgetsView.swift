//
//  AvailableWidgetsView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 16/04/2025.
//

import SwiftUI

struct AvailableWidgetsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingDarkWidgets = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Toggle("Show Dark Widgets", isOn: $isShowingDarkWidgets)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    
                    ForEach(WidgetOverview.all) { widgetOverview in
                        VStack(spacing: 0) {
                            Text(widgetOverview.title + " Widgets")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(12)
                            
                            Image(isShowingDarkWidgets ? widgetOverview.darkImage : widgetOverview.lightImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(.rect(cornerRadius: 24))
                            
                        }
                        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .black)
                        .clipShape(.rect(cornerRadius: 24))
                    }
                }
                .padding()
            }
            .navigationTitle("Widgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PlainIconButton(systemImage: "xmark", size: 12) {
                        dismiss()
                    }
                }
            }
            .animation(.default, value: isShowingDarkWidgets)
        }
    }
}

private struct WidgetOverview: Identifiable {
    let id = UUID()
    let title: String
    let lightImage: ImageResource
    let darkImage: ImageResource
    
    static let all = [
        WidgetOverview(title: "Next Prayer", lightImage: .nextPrayerLockScreenLightWidgets, darkImage: .nextPrayerLockScreenDarkWidgets),
        WidgetOverview(title: "Hijri Date", lightImage: .hijriDateLockScreenLightWidgets, darkImage: .hijriDateLockScreenDarkWidgets),
        WidgetOverview(title: "Next Prayer", lightImage: .nextPrayerHomeScreenLightWidgets, darkImage: .nextPrayerHomeScreenDarkWidgets),
        WidgetOverview(title: "Prayer Times", lightImage: .prayerTimesHomeScreenLightWidgets, darkImage: .prayerTimesHomeScreenDarkWidgets),
    ]
}

#Preview {
    AvailableWidgetsView()
        .tint(Color(.label))
}
