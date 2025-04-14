//
//  SpecificDateArchivedPrayerTimes.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 14/04/2025.
//

import Foundation
import SwiftData

@Model
class SpecificDateArchivedPrayerTimes {
    var date: Date
    var city: String
    var countryCode: String
    var apiResponseData: Data
    
    init(date: Date, city: String, countryCode: String, apiResponseData: Data) {
        self.date = date
        self.city = city
        self.countryCode = countryCode
        self.apiResponseData = apiResponseData
    }
    
    func getPrayerTimesInfo() throws -> PrayerTimesInfo {
        let decodedResponse = try JSONDecoder().decode(DayPrayerTimesAPIResponse.self, from: apiResponseData)
        return decodedResponse.data
    }
}
