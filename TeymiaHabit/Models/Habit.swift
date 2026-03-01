// File: TeymiaHabit/Models/Habit.swift
import Foundation
import SwiftData

/// Core habit model that represents a user's habit with progress tracking
/// Supports both count-based habits (e.g., "drink 8 glasses") and time-based habits (e.g., "read 30 minutes")
@Model
final class Habit {
    
    // MARK: - Identity
    var uuid: UUID = UUID()
    
    // MARK: - Basic Properties
    var title: String = ""
    var type: HabitType = HabitType.count
    var goal: Int = 1
    var iconName: String? = "check"
    var iconColor: HabitIconColor = HabitIconColor.primary
    var scheduledTime: HabitTimeOfDay = HabitTimeOfDay.anytime
    var priority: HabitPriority = HabitPriority.medium
    
    // MARK: - Status
    var isArchived: Bool = false
    var skippedDates: [Date] = []
    
    // MARK: - Timestamps
    var createdAt: Date = Date()
    var startDate: Date = Date()
    var displayOrder: Int = 0
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]?
    
    @Relationship(deleteRule: .cascade, inverse: \HabitSubtask.habit)
    var subtasks: [HabitSubtask]?
    
    // MARK: - Data Storage Configuration
    var activeDaysBitmask: Int = 0b1111111
    
    @Attribute(.externalStorage)
    var reminderTimesData: Data? // Made internal so extensions can compute the [Date] array
    
    // MARK: - Initializer
    init(
        title: String = "",
        type: HabitType = .count,
        goal: Int = 1,
        iconName: String? = "check",
        iconColor: HabitIconColor = .primary,
        scheduledTime: HabitTimeOfDay = .anytime,
        priority: HabitPriority = .medium,
        createdAt: Date = Date(),
        activeDays: [Bool]? = nil,
        reminderTimes: [Date]? = nil,
        startDate: Date = Date()
    ) {
        self.uuid = UUID()
        self.title = title
        self.type = type
        self.goal = goal
        self.iconName = iconName
        self.iconColor = iconColor
        self.scheduledTime = scheduledTime
        self.priority = priority
        self.createdAt = createdAt
        self.completions = []
        self.subtasks = []
        self.startDate = Calendar.current.startOfDay(for: startDate)
        
        if let days = activeDays {
            let orderedWeekdays = Weekday.orderedByUserPreference
            var bitmask = 0
            for (index, isActive) in days.enumerated() where index < 7 {
                if isActive {
                    bitmask |= (1 << orderedWeekdays[index].rawValue)
                }
            }
            self.activeDaysBitmask = bitmask
        } else {
            self.activeDaysBitmask = Habit.createDefaultActiveDaysBitMask()
        }
        
        // This leverages the computed property we will define in the properties extension
        self.reminderTimes = reminderTimes
    }
}
