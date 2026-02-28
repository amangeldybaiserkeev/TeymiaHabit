//
//  HabitPriority.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 28.02.26.
//
// File: TeymiaHabit/Models/HabitPriority.swift
import Foundation

/// Repräsentiert die Priorität einer Gewohnheit
enum HabitPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high
    
    var id: String { self.rawValue }
    
    /// Lokalisierter Anzeigename
    var localizedName: String {
        switch self {
        case .low: return "priority_low".localized
        case .medium: return "priority_medium".localized
        case .high: return "priority_high".localized
        }
    }
    
    /// Passendes Icon für die Prioritätsstufe
    var iconName: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "arrow.right"
        case .high: return "arrow.up" // Alternativ: "exclamationmark.3"
        }
    }
}
