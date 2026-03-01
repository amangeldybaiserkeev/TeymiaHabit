//
//  Habit+ActiveDays.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

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
    /// Considers both the start date and active weekdays
    func isActiveOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.userPreferred
        let dateStartOfDay = calendar.startOfDay(for: date)
        let startDateOfDay = calendar.startOfDay(for: startDate)
        
        if dateStartOfDay < startDateOfDay {
            return false
        }
        
        let weekday = Weekday.from(date: date)
        return isActive(on: weekday)
    }
    
    static func createDefaultActiveDaysBitMask() -> Int {
        return 0b1111111 // All days active
    }
}
