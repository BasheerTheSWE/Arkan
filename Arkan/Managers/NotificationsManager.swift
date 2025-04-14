//
//  NotificationsManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import Foundation
import UserNotifications

class NotificationsManager {
    
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
    
    static func schedulePrayerTimesNotificationsForTheNext30Days() async throws {
        let latitude = UserDefaults.shared.double(forKey: UDKey.latitude.rawValue)
        let longitude = UserDefaults.shared.double(forKey: UDKey.longitude.rawValue)
        
        /// First thing to do is to download the prayer times for the next 30 days
        /// Getting the starting and end dates
        let startingDate = Date()
        let endingDate = Calendar.current.date(byAdding: .day, value: 30, to: startingDate)!
        
        /// Getting the API response date
        let apiResponseData = try await NetworkManager.getPrayerTimesAPIResponseData(from: startingDate, to: endingDate, latitude: latitude, longitude: longitude)
        
        /// Decoding the API response data to get an array containing the prayer times for the next 30 days
        let decodedAPIResponse = try JSONDecoder().decode(PrayerTimesForSpecificPeriodAPIResponse.self, from: apiResponseData)
        let prayerTimesInfosForTheNext30Days = decodedAPIResponse.data
        
        /// Now we loop through the downloaded data and schedule a notification for every prayer
        for prayerTimesInfo in prayerTimesInfosForTheNext30Days {
            for index in 0..<5 {
                let prayer = Prayer.allCases[index]
                let notificationBody = prayer == .fajr ? "Prayer is better than sleep 🕊️" : (prayerTimeNotificationBodies.randomElement() ?? "Prayer is better than sleep 🕊️")
                
                let timeString = prayerTimesInfo.timings.getTime(for: prayer, use24HourFormat: true) // format: hh:mm
                let dateString = prayerTimesInfo.date.gregorian.date // In the format of dd-MM-yyyy
                
                if let prayerDateComponents = getDateComponents(timeString: timeString, dateString: dateString) {
                    scheduleNotification(title: "Time for \(prayer.rawValue)", body: notificationBody, dateMatching: prayerDateComponents)
                }
            }
        }
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
    
    // MARK: - PRIVATE
    static func getDateComponents(timeString: String, dateString: String) -> DateComponents? {
        let dateTimeString = "\(dateString) \(timeString)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateTimeString) else { return nil }
        
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
}
