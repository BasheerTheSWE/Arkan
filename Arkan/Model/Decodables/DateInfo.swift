//
//  DateInfo.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

struct DateInfo: Decodable {
    let gregorian: GregorianDate
    let hijri: HijriDate
}
