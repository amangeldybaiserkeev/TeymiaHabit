//
//  Habit+Progress.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Models/Habit+Progress.swift
import Foundation
import SwiftData

// MARK: - Progress Tracking
extension Habit {
    
    func progressForDate(_ date: Date) -> Int {
        guard let completions = completions else { return 0 }
        
        let calendar = Calendar.current
        let filteredCompletions = completions.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        
        return filteredCompletions.reduce(0) { $0 + $1.value }
    }
    
    func formatProgress(_ progress: Int) -> String {
        switch type {
        case .count:
            return "\(progress)"
        case .time:
            return progress.formattedAsTime()
        }
    }
    
    func formattedProgress(for date: Date) -> String {
        let progress = progressForDate(date)
        return formatProgress(progress)
    }
    
    @MainActor
    func liveProgress(for date: Date) -> Int {
        // In widgets, only use database progress for performance
        progressForDate(date)
    }

    @MainActor
    func formattedLiveProgress(for date: Date) -> String {
        let progress = liveProgress(for: date)
        return formatProgress(progress)
    }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        progressForDate(date) >= goal
    }
    
    func isExceededForDate(_ date: Date) -> Bool {
        progressForDate(date) > goal
    }
    
    func completionPercentageForDate(_ date: Date) -> Double {
        let progress = min(progressForDate(date), 999999) // Cap extremely high values
        
        if goal <= 0 {
            return progress > 0 ? 1.0 : 0.0
        }
        
        let percentage = Double(progress) / Double(goal)
        return min(percentage, 1.0) // Cap at 100%
    }
    
    func addProgress(_ value: Int, for date: Date = .now) {
        let completion = HabitCompletion(date: date, value: value, habit: self)
        
        if completions == nil {
            completions = []
        }
        completions?.append(completion)
    }
}

// MARK: - Goal Formatting
extension Habit {
    
    var formattedGoal: String {
        switch type {
        case .count:
            return "\(goal)"
        case .time:
            return goal.formattedAsLocalizedDuration()
        }
    }
}
