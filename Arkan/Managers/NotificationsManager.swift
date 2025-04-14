//
//  NotificationsManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import Foundation
import UserNotifications

class NotificationsManager {
    
    static func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    static func schedulePrayerTimesNotificationsForTheNext30Days() {
        
    }
    
    static func scheduleNotification(title: String, body: String, dateMatching: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateMatching, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
