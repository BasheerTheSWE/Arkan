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
    
    @MainActor
    static func getPrayerTimesAPIResponseData(forYear year: Int, latitude: Double, longitude: Double) async throws -> Data {
        guard let url = URL(string: "https://api.aladhan.com/v1/calendar/\(year)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        return data
    }
    
    @MainActor
    static func getPrayerTimes(forDate date: Date, city: String, countryCode: String) async throws -> PrayerTimesInfo {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = formatter.string(from: date)
        
        guard let url = URL(string: "https://api.aladhan.com/v1/timingsByCity/\(formattedDate)?city=\(city)&country=\(countryCode)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        return try await getPrayerTimesInfoFromURL(url: url)
    }
    
    @MainActor
    static func getPrayerTimes(forDate date: Date, latitude: Double, longitude: Double) async throws -> PrayerTimesInfo {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = formatter.string(from: date)
        
        guard let url = URL(string: "https://api.aladhan.com/v1/timings/\(formattedDate)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        return try await getPrayerTimesInfoFromURL(url: url)
    }
    
    // MARK: - REUSABLES
    static private func getPrayerTimesInfoFromURL(url: URL) async throws -> PrayerTimesInfo {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        let decodedPrayerTimesAPIResponse = try JSONDecoder().decode(DayPrayerTimesAPIResponse.self, from: data)
        return decodedPrayerTimesAPIResponse.data
    }
}
