//
//  NetworkManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

final class NetworkManager {
    
    enum NetworkError: Error {
        case invalidURL
        case badServerResponse
    }
    
    static func getPrayerTimes(forYear year: Int, city: String, countryCode: String) async throws -> [String: [PrayerDay]] {
        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity/\(year)?city=\(city)&country=\(countryCode)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        /// Caching the downloaded prayer times into CoreData and removing previous saves for the passed-in year if any were found
        if let context = try? ModelContext(.init(for: GregorianYearPrayerTimes.self)) {
            let fetchDescriptor = FetchDescriptor<GregorianYearPrayerTimes>(predicate: #Predicate { $0.year == year && $0.city == city && $0.countryCode == countryCode })
            
            /// Getting all existing duplicates if there were any
            if let existingDuplicates = try? context.fetch(fetchDescriptor) {
                existingDuplicates.forEach { duplicate in
                    context.delete(duplicate)
                }
            }
            
            /// Saving the newly downloaded prayer times
            let prayerTimes = GregorianYearPrayerTimes(year: year, city: city, countryCode: countryCode, apiResponseData: data)
            context.insert(prayerTimes)
            try? context.save()
        }
        
        let decodedPrayerTimesAPIResponse = try JSONDecoder().decode(GregorianYearPrayerTimesAPIResponse.self, from: data)
        return decodedPrayerTimesAPIResponse.data
    }
    
//    static func getPrayerTimes(forDate dateComponents: DateComponents) {
//        guard let url = URL(string: "https://api.aladhan.com/v1/timingsByCity/12-04-2025?city=Taif&country=SA&shafaq=general&calendarMethod=UAQ") else { return }
//    }
}
