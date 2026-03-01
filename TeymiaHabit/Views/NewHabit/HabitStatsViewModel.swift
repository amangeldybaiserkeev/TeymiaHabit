//
//  HabitStatsViewModel.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/ViewModels/HabitStatsViewModel.swift
import SwiftUI
import SwiftData

@Observable
class HabitStatsViewModel {
    let habit: Habit
    
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var totalValue: Int = 0
    
    init(habit: Habit) {
        self.habit = habit
        calculateStats()
    }
    
    func refresh() {
        calculateStats()
    }
    
    func calculateStats() {
        let completions = habit.completions ?? []
        totalValue = completions.reduce(0) { $0 + $1.value }
        
        calculateStreaks()
    }
    
    private func calculateStreaks() {
        let calendar = Calendar.current
        var streak = 0
        var maxStreak = 0
        
        // Wir starten beim aktuellen Intervall (heute/diese Woche/dieser Monat)
        var checkDate = calendar.startOfDay(for: Date())
        let firstCompletionDate = habit.startDate
        
        // 1. Current Streak berechnen (Rückwärts von heute)
        while checkDate >= firstCompletionDate {
            if habit.isCompletedForDate(checkDate) {
                streak += 1
                // Springe zum Start des VORHERIGEN Intervalls
                checkDate = getPreviousIntervalDate(from: checkDate)
            } else {
                // Wenn heute noch nicht fertig, aber gestern/letzte Woche war fertig -> Streak lebt noch
                if streak == 0 {
                    checkDate = getPreviousIntervalDate(from: checkDate)
                    if checkDate >= firstCompletionDate && habit.isCompletedForDate(checkDate) {
                        continue // Gehe in die Schleife für gestern zurück
                    }
                }
                break
            }
        }
        currentStreak = streak
        
        // 2. Best Streak (Einfachheitshalber nutzen wir hier aktuell den Max-Wert)
        // Für eine historisch exakte "Best Streak" über Intervalle hinweg
        // müsste man die gesamte Historie iterieren.
        bestStreak = max(currentStreak, bestStreak)
    }
    
    private func getPreviousIntervalDate(from date: Date) -> Date {
        let calendar = Calendar.current
        let currentInterval = habit.dateInterval(for: date)
        // Wir gehen einen Tag vor den Start des aktuellen Intervalls,
        // um sicher im vorherigen Zeitraum zu landen.
        return calendar.date(byAdding: .day, value: -1, to: currentInterval.start) ??
               calendar.date(byAdding: .day, value: -1, to: date)!
    }
}
