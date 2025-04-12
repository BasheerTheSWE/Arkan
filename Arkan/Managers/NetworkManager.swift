//
//  NetworkManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

final class NetworkManager {
    
    enum NetworkError: Error {
        case invalidURL
    }
    
    static func getPrayerTimes(forYear year: Int, city: String, countryCode: String) async throws -> [String: [PrayerDay]] {
        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity/\(year)?city=\(city)&country=\(countryCode)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let prayerTimesCalendar = try JSONDecoder().decode(PrayerTimesCalendar.self, from: data)
        return prayerTimesCalendar.data
    }
    
//    static func getPrayerTimes(forDate dateComponents: DateComponents) {
//        guard let url = URL(string: "https://api.aladhan.com/v1/timingsByCity/12-04-2025?city=Taif&country=SA&shafaq=general&calendarMethod=UAQ") else { return }
//    }
}
