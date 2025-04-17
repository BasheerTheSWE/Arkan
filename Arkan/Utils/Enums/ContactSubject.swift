//
//  ContactSubject.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 17/04/2025.
//

import Foundation

enum ContactSubject: String, Identifiable {
    case contactUs = "Feedback Regarding Arkan"
    case featureRequest = "Arkan - Feature Request"
    case bugReport = "Arkan - Bug Report"
    case widgetRequest = "Arkan - Widget Request"
    
    var id: String { self.rawValue }
}
