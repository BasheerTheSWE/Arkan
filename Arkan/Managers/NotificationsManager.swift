//
//  NotificationsManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import Foundation
import UserNotifications

class NotificationsManager {
    
    enum NotificationError: Error {
        case notAuthorized
    }
    
    static let prayerTimeNotificationBodies = [
        "Take a moment to connect with Allah ﷻ.",
        "Time to pause and remember Allah.",
        "May your prayer bring peace to your heart 🤲.",
        "Don’t miss your prayer. Allah is waiting for you.",
        "A chance to speak directly to the Most Merciful.",
        "Let your soul breathe — it’s time for salah.",
        "In the remembrance of Allah do hearts find rest. ﷻ",
        "Your soul needs this — go pray.",
        "Another opportunity to earn reward — don’t miss it.",
        "The Prophet ﷺ said: Prayer is the key to Jannah.",
        "Time to rise in remembrance 🌙",
        "Recharge your soul — it’s prayer time.",
        "A new prayer, a new beginning, a new reward.",
        "Meet your Lord in peace — go pray.",
        "Let this prayer be your best one yet.",
        "One prayer closer to Jannah, in shā’ Allāh.",
        "Allah is calling — will you answer?",
        "It’s prayer time — your meeting with The King 👑.",
        "Quiet your mind. It’s time for salah."
    ]
    
    static func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    /// Schedules prayer times notifications for the next 30 days
    ///
    /// > Important: Make sure to update the user's location before calling this method
    static func schedulePrayerTimesNotificationsForTheNext30Days() async throws {
        guard try await requestAuthorization() else { throw NotificationError.notAuthorized }
        
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        let isFajrNotificationDisabled = UserDefaults.shared.bool(forKey: UDKey.isFajrNotificationDisabled.rawValue)
        let isDhuhrNotificationDisabled = UserDefaults.shared.bool(forKey: UDKey.isDhuhrNotificationDisabled.rawValue)
        let isAsrNotificationDisabled = UserDefaults.shared.bool(forKey: UDKey.isAsrNotificationDisabled.rawValue)
        let isMaghribNotificationDisabled = UserDefaults.shared.bool(forKey: UDKey.isMaghribNotificationDisabled.rawValue)
        let isIshaNotificationDisabled = UserDefaults.shared.bool(forKey: UDKey.isIshaNotificationDisabled.rawValue)
        
        /// First thing to do is to download the prayer times for the next 30 days
        /// Getting the starting and end dates
        let startingDate = Date()
        let endingDate = Calendar.current.date(byAdding: .day, value: 30, to: startingDate)!
        
        /// Getting the API response date
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(from: startingDate, to: endingDate, latitude: latitude, longitude: longitude)
        
        /// Decoding the API response data to get an array containing the prayer times for the next 30 days
        let decodedAPIResponse = try JSONDecoder().decode(PrayerTimesForSpecificPeriodAPIResponse.self, from: apiResponseData)
        let prayerTimesInfosForTheNext30Days = decodedAPIResponse.data
        
        /// We'll clear previous or to be more precise 'upcoming' notifications before we schedule the new ones
        clearScheduledNotifications()
        
        /// Now we loop through the downloaded data and schedule a notification for every prayer
        for prayerTimesInfo in prayerTimesInfosForTheNext30Days {
            for index in 0..<5 {
                let prayer = Prayer.allCases[index]
                
                /// Before scheduling the prayer time's notification we'll check if the user has enabled the notification for it.
                switch prayer {
                case .fajr:
                    if isFajrNotificationDisabled { continue }
                    
                case .dhuhr:
                    if isDhuhrNotificationDisabled { continue }
                    
                case .asr:
                    if isAsrNotificationDisabled { continue }
                    
                case .maghrib:
                    if isMaghribNotificationDisabled { continue }
                    
                case .isha:
                    if isIshaNotificationDisabled { continue }
                }
                
                let notificationBody = prayer == .fajr ? "Prayer is better than sleep 🕊️" : (prayerTimeNotificationBodies.randomElement() ?? "Prayer is better than sleep 🕊️")
                
                let timeString = prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true) // format: hh:mm
                let dateString = prayerTimesInfo.date.gregorian.date // In the format of dd-MM-yyyy
                
                if let prayerDate = getPrayerDate(timeString: timeString, dateString: dateString) {
                    print("Notification was scheduled for \(prayer.rawValue)")
                    scheduleNotification(title: "Time for \(prayer.rawValue)", body: notificationBody, date: prayerDate)
                }
            }
        }
    }
    
    static func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(in: .current, from: date), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func clearScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - PRIVATE
    static func getPrayerDate(timeString: String, dateString: String) -> Date? {
        let dateTimeString = "\(dateString) \(timeString)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.date(from: dateTimeString)
    }
}
