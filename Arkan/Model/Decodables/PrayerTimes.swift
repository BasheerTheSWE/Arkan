//
//  PrayerTimes.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct PrayerTimes: Decodable {
    
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    
    /// The API returns time looking like this "19:18 (+03)" ... This method will get the time part and formatted to be either 12-24 hrs based.
    /// - Parameters:
    ///   - prayer: The prayer you want to get the formatted time for.
    ///   - use24HourFormat: Sets the desired time format.
    /// - Returns: Clean `String` containing the passed-in prayer time.
    func getTime(for prayer: Prayer, use24HourFormat: Bool = false) -> String {
        /// Getting the ugly API time string in the form of --> "19:18 (+03)"
        let timeString = {
            switch prayer {
            case .fajr:
                return Fajr
            case .dhuhr:
                return Dhuhr
            case .asr:
                return Asr
            case .maghrib:
                return Maghrib
            case .isha:
                return Isha
            }
        }()
        
        /// Extracting the time part from the API time string and formatting it
        let timePart = timeString.components(separatedBy: " ").first ?? timeString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: timePart) else { return timePart }
        
        formatter.dateFormat = use24HourFormat ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }
}
