//
//  GregorianYearPrayerTimesAPIResponse.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct GregorianYearPrayerTimesAPIResponse: Decodable {
    let data: [String: [PrayerTimesInfo]]
}
