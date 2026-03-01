//
//  Habit+Properties.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Models/Habit+Properties.swift
import Foundation
import SwiftData

// MARK: - Properties & Updates
extension Habit {
    
    /// Unique string identifier
    var id: String {
        uuid.uuidString
    }
    
    // MARK: - Reminders
    
    /// Computed property for accessing reminder times as a Date array.
    /// Serializes and deserializes from the underlying Data attribute.
    var reminderTimes: [Date]? {
        get {
            guard let data = reminderTimesData else { return nil }
            return try? JSONDecoder().decode([Date].self, from: data)
        }
        set {
            if let times = newValue, !times.isEmpty {
                reminderTimesData = try? JSONEncoder().encode(times)
            } else {
                reminderTimesData = nil
            }
        }
    }
    
    var hasReminders: Bool {
        reminderTimes != nil && !(reminderTimes?.isEmpty ?? true)
    }
    
    // MARK: - Update
    
    func update(
        title: String,
        type: HabitType,
        goal: Int,
        iconName: String?,
        iconColor: HabitIconColor,
        scheduledTime: HabitTimeOfDay,
        priority: HabitPriority,
        activeDays: [Bool],
        reminderTimes: [Date]?,
        startDate: Date
    ) {
        self.title = title
        self.type = type
        self.goal = goal
        self.iconName = iconName
        self.iconColor = iconColor
        self.scheduledTime = scheduledTime
        self.priority = priority
        self.activeDays = activeDays
        self.reminderTimes = reminderTimes
        self.startDate = startDate
    }
}
