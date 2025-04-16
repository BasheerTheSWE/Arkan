//
//  Prayer.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import Foundation

enum Prayer: String, CaseIterable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    func getSystemImage() -> String {
        let images = [
            "sunrise",
            "sun.max",
            "cloud.sun",
            "sunset",
            "moon"
        ]
        
        return images[Prayer.allCases.firstIndex(of: self) ?? 0]
    }
    
    func getAbbreviatedName() -> String {
        switch self {
        case .fajr:
            "FJR"
            
        case .dhuhr:
            "DHR"
            
        case .asr:
            "ASR"
            
        case .maghrib:
            "MGB"
            
        case .isha:
            "ISH"
        }
    }
}
