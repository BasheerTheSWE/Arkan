//
//  Timings.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct Timings: Decodable {
    
    enum Timing { case fajr, dhuhr, asr, maghrib, isha }
    
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    
    func getTime(for timing: Timing, use24HourFormat: Bool = false) -> String {
        let timeString = {
            switch timing {
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
        
        let timePart = timeString.components(separatedBy: " ").first ?? timeString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: timePart) else { return timePart }
        
        formatter.dateFormat = use24HourFormat ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }
}
