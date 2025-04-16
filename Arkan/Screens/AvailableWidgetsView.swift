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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(WidgetOverview.all) { widgetOverview in
                        VStack {
                            
                        }
                    }
                }
            }
            .navigationTitle("Widgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PlainIconButton(systemImage: "xmark", size: 12) {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct WidgetOverview: Identifiable {
    let id = UUID()
    let title: String
    let imageResource: ImageResource
    
    static let all = [
        WidgetOverview(title: "Next Prayer", imageResource: .nextPrayerLockScreenWidgets),
        WidgetOverview(title: "Hijri Date", imageResource: .hijriDateLockScreenWidgets),
        WidgetOverview(title: "Next Prayer", imageResource: .nextPrayerHomeScreenWidgets),
        WidgetOverview(title: "Prayer Times", imageResource: .prayerTimesHomeScreenWidgets),
    ]
}

#Preview {
    AvailableWidgetsView()
        .tint(Color(.label))
}
