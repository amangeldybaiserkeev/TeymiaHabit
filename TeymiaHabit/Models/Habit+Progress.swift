// File: TeymiaHabit/Models/Habit+Progress.swift
import Foundation
import SwiftData

// MARK: - Progress Tracking
extension Habit {
    
    /// Berechnet das relevante Zeitintervall basierend auf der eingestellten Frequenz.
    func dateInterval(for date: Date) -> DateInterval {
        let calendar = Calendar.current
        switch frequency {
        case .daily:
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
            return DateInterval(start: start, end: end)
            
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, end: date)
            
        case .monthly:
            return calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, end: date)
            
        case .custom:
            guard let startWd = customStartWeekday, let endWd = customEndWeekday else {
                return calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, end: date)
            }
            // Custom: Suche Starttag in der Vergangenheit/Gegenwart
            var start = date
            while Weekday.from(date: start) != startWd {
                start = calendar.date(byAdding: .day, value: -1, to: start) ?? start
            }
            start = calendar.startOfDay(for: start)
            
            // Custom: Suche Endtag in der Zukunft (ausgehend vom Start)
            var end = start
            while Weekday.from(date: end) != endWd {
                end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
            }
            end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
            return DateInterval(start: start, end: end)
        }
    }
    
    func progressForDate(_ date: Date) -> Int {
        guard let completions = completions else { return 0 }
        let interval = dateInterval(for: date)
        
        let filteredCompletions = completions.filter {
            interval.contains($0.date)
        }
        
        return filteredCompletions.reduce(0) { $0 + $1.value }
    }
    
    func formatProgress(_ progress: Int) -> String {
        switch type {
        case .count: return "\(progress)"
        case .time: return progress.formattedAsTime()
        }
    }
    
    func formattedProgress(for date: Date) -> String {
        return formatProgress(progressForDate(date))
    }
    
    @MainActor
    func liveProgress(for date: Date) -> Int {
        progressForDate(date)
    }

    @MainActor
    func formattedLiveProgress(for date: Date) -> String {
        formatProgress(liveProgress(for: date))
    }
    
    /// Nutzt frequencyGoal falls vorhanden, sonst das Standard-Goal
    var targetGoal: Int { frequencyGoal ?? goal }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        progressForDate(date) >= targetGoal
    }
    
    func isExceededForDate(_ date: Date) -> Bool {
        progressForDate(date) > targetGoal
    }
    
    func completionPercentageForDate(_ date: Date) -> Double {
        let progress = min(progressForDate(date), 999999)
        if targetGoal <= 0 { return progress > 0 ? 1.0 : 0.0 }
        let percentage = Double(progress) / Double(targetGoal)
        return min(percentage, 1.0)
    }
    
    func addProgress(_ value: Int, for date: Date = .now) {
        if completions == nil { completions = [] }
        completions?.append(HabitCompletion(date: date, value: value, habit: self))
    }
}

// MARK: - Goal Formatting
extension Habit {
    
    var formattedGoal: String {
        switch type {
        case .count: return "\(targetGoal)"
        case .time: return targetGoal.formattedAsLocalizedDuration()
        }
    }
}
