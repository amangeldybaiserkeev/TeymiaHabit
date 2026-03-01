//
//  HabitFrequency.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Models/HabitFrequency.swift
import Foundation

/// Definiert die verschiedenen Frequenz-Intervalle für eine Gewohnheit.
/// Abwärtskompatibel: 'daily' entspricht dem bisherigen Standard-Verhalten.
enum HabitFrequency: Int, Codable, CaseIterable {
    case daily = 0
    case weekly = 1
    case monthly = 2
    case custom = 3
    
    var localizedName: String {
        switch self {
        case .daily:
            return String(localized: "Täglich", defaultValue: "Täglich")
        case .weekly:
            return String(localized: "Wöchentlich", defaultValue: "Wöchentlich")
        case .monthly:
            return String(localized: "Monatlich", defaultValue: "Monatlich")
        case .custom:
            return String(localized: "Benutzerdefiniert", defaultValue: "Benutzerdefiniert")
        }
    }
}
