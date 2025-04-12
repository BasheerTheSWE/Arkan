//
//  NetworkManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

final class NetworkManager {
    
    static func getPrayerTimes(forYear year: Int, city: String, countryCode: String) async throws {
        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity/\(year)?city=\(city)&country=\(countryCode)&shafaq=general&calendarMethod=UAQ") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(try JSONSerialization.jsonObject(with: data))
        print(response)
    }
    
//    static func getPrayerTimes(forDate dateComponents: DateComponents) {
//        guard let url = URL(string: "https://api.aladhan.com/v1/timingsByCity/12-04-2025?city=Taif&country=SA&shafaq=general&calendarMethod=UAQ") else { return }
//    }
}
