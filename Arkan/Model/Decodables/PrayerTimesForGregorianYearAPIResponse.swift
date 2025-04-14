//
//  PrayerTimesForGregorianYearAPIResponse.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct PrayerTimesForGregorianYearAPIResponse: Decodable {
    let data: [String: [PrayerTimesInfo]]
}
