//
//  HijriDate.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct HijriDate: Decodable {
    let date: String
    let format: String
    let day: String
    let weekday: HijriWeekday
    let month: HijriMonth
    let year: String
    
    static let mock = HijriDate(date: "18-10-1446", format: "DD-MM-YYYY", day: "18", weekday: HijriWeekday(en: "Al Arba'a", ar: "الاربعاء"), month: HijriMonth(number: 10, en: "Shawwāl", ar: "شَوّال"), year: "1446")
}
