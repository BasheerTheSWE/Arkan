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
    
    static func getPrayerTimesAPIResponseData(from startingDate: Date, to endingDate: Date, latitude: Double, longitude: Double) async throws -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let formattedStartingDate = formatter.string(from: startingDate)
        let formattedEndingDate = formatter.string(from: endingDate)
        
        guard let url = URL(string: "https://api.aladhan.com/v1/calendar/from/\(formattedStartingDate)/to/\(formattedEndingDate)?latitude=\(latitude)&longitude=\(longitude)&shafaq=general&calendarMethod=UAQ") else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.badServerResponse }
        
        return data
    }
}
