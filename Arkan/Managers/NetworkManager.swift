//
//  NetworkManager.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

@MainActor
final class NetworkManager {
    
    enum NetworkError: Error {
        case invalidURL
        case badServerResponse
    }
    
    static func getPrayerTimesAPIResponseData(forYear year: Int, latitude: Double, longitude: Double) async throws -> Data {
        guard let url = URL(string: "https://api.aladhan.com/v1/calendar/\(year)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        return data
    }
    
    static func getPrayerTimesAPIResponseData(forDate date: Date, latitude: Double, longitude: Double) async throws -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = formatter.string(from: date)
        
        guard let url = URL(string: "https://api.aladhan.com/v1/timings/\(formattedDate)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        return data
    }
    
    /// Downloads the prayer times for a specified period.
    ///
    /// But weird thing is happening, the response's prayer times are always in UTC and you'll have to convert them to the user's local timing.
    ///
    /// - Parameters:
    ///   - startingDate: The starting date of the range.
    ///   - endingDate: The ending date of the range.
    ///   - latitude: The latitude of the user's location to get accurate prayer times.
    ///   - longitude: The longitude of the user's location to get accurate prayer times.
    /// - Returns: API response's data ... should be decoded using ``PrayerTimesForSpecificPeriodAPIResponse``.
    static func getPrayerTimesAPIResponseData(from startingDate: Date, to endingDate: Date, latitude: Double, longitude: Double) async throws -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let formattedStartingDate = formatter.string(from: startingDate)
        let formattedEndingDate = formatter.string(from: endingDate)
        
        guard let url = URL(string: "https://api.aladhan.com/v1/calendar/from/\(formattedStartingDate)/to/\(formattedEndingDate)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&timezonestring=UTC&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        /// Since this response will be called every time the user launches the app, it's better to cache it
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        return data
    }
}
