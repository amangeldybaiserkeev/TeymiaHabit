//
//  Habit+Operations.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Models/Habit+Operations.swift
import Foundation
import SwiftData

// MARK: - SwiftData Operations
extension Habit {
    
    func updateProgress(to newValue: Int, for date: Date, modelContext: ModelContext) {
        if let existingCompletions = completions?.filter({
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            for completion in existingCompletions {
                modelContext.delete(completion)
            }
        }
        
        if newValue > 0 {
            let completion = HabitCompletion(
                date: date,
                value: newValue,
                habit: self
            )
            modelContext.insert(completion)
        }
        
        try? modelContext.save()
    }
    
    func addToProgress(_ additionalValue: Int, for date: Date, modelContext: ModelContext) {
        let currentValue = progressForDate(date)
        let newValue = max(0, currentValue + additionalValue)
        updateProgress(to: newValue, for: date, modelContext: modelContext)
    }
    
    func complete(for date: Date, modelContext: ModelContext) {
        updateProgress(to: goal, for: date, modelContext: modelContext)
    }
    
    func resolveProgressForDay(for date: Date, modelContext: ModelContext) {
         updateProgress(to: 0, for: date, modelContext: modelContext)
    }
    
    func resetProgress(for date: Date, modelContext: ModelContext) {
        updateProgress(to: 0, for: date, modelContext: modelContext)
    }
}

// MARK: - Skip Management
extension Habit {
    func isSkipped(on date: Date) -> Bool {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        return skippedDates.contains { calendar.isDate($0, inSameDayAs: dateStart) }
    }
    
    func skipDate(_ date: Date, modelContext: ModelContext) {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        
        if !isSkipped(on: dateStart) {
            skippedDates.append(dateStart)
            try? modelContext.save()
        }
    }
    
    func unskipDate(_ date: Date, modelContext: ModelContext) {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        
        skippedDates.removeAll { calendar.isDate($0, inSameDayAs: dateStart) }
        try? modelContext.save()
    }
}
