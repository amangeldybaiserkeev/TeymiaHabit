// File: TeymiaHabit/Models/Habit+Properties.swift
import Foundation
import SwiftData

// MARK: - Properties & Updates
extension Habit {
    
    /// Unique string identifier
    var id: String {
        uuid.uuidString
    }
    
    // MARK: - Frequency Helpers
    
    var frequency: HabitFrequency {
        get { HabitFrequency(rawValue: frequencyRawValue) ?? .daily }
        set { frequencyRawValue = newValue.rawValue }
    }
    
    var customStartWeekday: Weekday? {
        get {
            guard let val = customPeriodStart else { return nil }
            return Weekday(rawValue: val)
        }
        set { customPeriodStart = newValue?.rawValue }
    }
    
    var customEndWeekday: Weekday? {
        get {
            guard let val = customPeriodEnd else { return nil }
            return Weekday(rawValue: val)
        }
        set { customPeriodEnd = newValue?.rawValue }
    }
    
    // MARK: - Reminders
    
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
        title: String, type: HabitType, goal: Int, iconName: String?,
        iconColor: HabitIconColor, scheduledTime: HabitTimeOfDay,
        priority: HabitPriority, activeDays: [Bool], reminderTimes: [Date]?,
        startDate: Date, frequency: HabitFrequency = .daily,
        frequencyGoal: Int? = nil, customStart: Weekday? = nil,
        customEnd: Weekday? = nil
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
        
        self.frequency = frequency
        self.frequencyGoal = frequencyGoal
        self.customStartWeekday = customStart
        self.customEndWeekday = customEnd
    }
}
