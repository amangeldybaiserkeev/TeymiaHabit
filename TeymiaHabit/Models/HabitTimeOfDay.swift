//
//  HabitTimeOfDay.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 28.02.26.
//

// File: TeymiaHabit/Models/HabitTimeOfDay.swift
import Foundation

/// Repräsentiert die geplante Tageszeit für eine Gewohnheit
enum HabitTimeOfDay: String, Codable, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening
    case night
    case anytime
    
    var id: String { self.rawValue }
    
    /// Lokalisierter Anzeigename
    var localizedName: String {
        switch self {
        case .morning: return "Morgens".localized
        case .afternoon: return "Mittags".localized
        case .evening: return "Nachmittags".localized
        case .night: return "Abend".localized
        case .anytime: return "Jeder Zeit".localized
        }
    }
    
    /// Passendes Icon für die Tageszeit
    var iconName: String {
        switch self {
        case .morning: return "sun.horizon.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        case .anytime: return "clock.fill"
        }
    }
}
