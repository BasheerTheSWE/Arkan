//
//  GregorianYearPrayerTimes.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation
import SwiftData

@Model
class GregorianYearPrayerTimes {
    var year: Int
    var city: String
    var countryCode: String
    var apiResponseData: Data
    
    init(year: Int, city: String, countryCode: String, apiResponseData: Data) {
        self.year = year
        self.city = city
        self.countryCode = countryCode
        self.apiResponseData = apiResponseData
    }
    
    /// Decodes the saved API response which contains an entire year's worth of prayer times divided by months.
    /// - Returns: A dictionary containing 12 items -one for each month- and each item contains 28-31 prayer times.
    func getPrayerTimesByMonths() throws -> [String: [PrayerDay]]{
        let decodedResponse = try JSONDecoder().decode(GregorianYearPrayerTimesAPIResponse.self, from: apiResponseData)
        return decodedResponse.data
    }
}
