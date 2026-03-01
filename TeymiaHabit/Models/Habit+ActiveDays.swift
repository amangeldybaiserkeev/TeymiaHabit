// File: TeymiaHabit/Models/Habit+ActiveDays.swift
import Foundation

// MARK: - Active Days Management
extension Habit {
    
    /// Computed property for UI compatibility - converts bitmask to bool array
    var activeDays: [Bool] {
        get {
            let orderedWeekdays = Weekday.orderedByUserPreference
            return orderedWeekdays.map { isActive(on: $0) }
        }
        set {
            let orderedWeekdays = Weekday.orderedByUserPreference
            activeDaysBitmask = 0
            for (index, isActive) in newValue.enumerated() where index < 7 {
                if isActive {
                    let weekday = orderedWeekdays[index]
                    setActive(true, for: weekday)
                }
            }
        }
    }
    
    func isActive(on weekday: Weekday) -> Bool {
        (activeDaysBitmask & (1 << weekday.rawValue)) != 0
    }
    
    func setActive(_ active: Bool, for weekday: Weekday) {
        if active {
            activeDaysBitmask |= (1 << weekday.rawValue)
        } else {
            activeDaysBitmask &= ~(1 << weekday.rawValue)
        }
    }
    
    /// Checks if habit should be tracked on a specific date
    /// Considers both the start date and active weekdays OR complex frequencies
    func isActiveOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.userPreferred
        let dateStartOfDay = calendar.startOfDay(for: date)
        let startDateOfDay = calendar.startOfDay(for: startDate)
        
        // Gewohnheit hat an diesem Datum noch gar nicht begonnen
        if dateStartOfDay < startDateOfDay {
            return false
        }
        
        switch frequency {
        case .daily:
            // Altbekanntes Verhalten für tägliche Gewohnheiten
            let weekday = Weekday.from(date: date)
            return isActive(on: weekday)
            
        case .weekly, .monthly:
            // Wöchentliche und monatliche Gewohnheiten sind in ihrem Zeitraum jeden Tag relevant,
            // da man sie sich frei einteilen kann.
            return true
            
        case .custom:
            // Bei benutzerdefinierten Zeiträumen wird geprüft, ob das angeklickte Datum
            // in das aktuell berechnete Arbeits-Intervall fällt.
            let interval = dateInterval(for: date)
            return interval.contains(dateStartOfDay)
        }
    }
    
    static func createDefaultActiveDaysBitMask() -> Int {
        return 0b1111111 // All days active
    }
}
