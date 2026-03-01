//
//  NewHabitView+Logic.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Views/NewHabit/NewHabitView+Logic.swift
import SwiftUI
import SwiftData

extension NewHabitView {
    
    var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasValidTitle = !trimmedTitle.isEmpty
        let hasValidGoal = selectedType == .count ? countGoal > 0 : (hours > 0 || minutes > 0)
        return hasValidTitle && hasValidGoal
    }
    
    var effectiveGoal: Int {
        if selectedType == .count { return countGoal }
        return min((hours * 3600) + (minutes * 60), 86400)
    }
    
    func saveHabit() {
        let targetHabit: Habit
        let start = frequency == .custom ? customPeriodStart : nil
        let end = frequency == .custom ? customPeriodEnd : nil
        
        if let existingHabit = habit {
            existingHabit.update(
                title: title, type: selectedType, goal: effectiveGoal,
                iconName: selectedIcon, iconColor: selectedIconColor,
                scheduledTime: scheduledTime, priority: priority, activeDays: activeDays,
                reminderTimes: isReminderEnabled ? reminderTimes : nil,
                startDate: Calendar.current.startOfDay(for: startDate),
                frequency: frequency, customStart: start, customEnd: end
            )
            targetHabit = existingHabit
        } else {
            let newHabit = Habit(
                title: title, type: selectedType, goal: effectiveGoal,
                iconName: selectedIcon, iconColor: selectedIconColor,
                scheduledTime: scheduledTime, priority: priority, createdAt: Date(),
                activeDays: activeDays, reminderTimes: isReminderEnabled ? reminderTimes : nil,
                startDate: startDate, frequency: frequency,
                customPeriodStart: start, customPeriodEnd: end
            )
            modelContext.insert(newHabit)
            targetHabit = newHabit
        }
        
        finalizeSave(for: targetHabit)
    }
    
    private func finalizeSave(for habit: Habit) {
        syncSubtasks(for: habit)
        handleNotifications(for: habit)
        WidgetUpdateService.shared.reloadWidgetsAfterDataChange()
        
        if let onSaveCompletion = onSaveCompletion {
            onSaveCompletion()
        } else {
            dismiss()
        }
    }
    
    private func syncSubtasks(for habit: Habit) {
        if let existingSubtasks = habit.subtasks {
            for subtask in existingSubtasks { modelContext.delete(subtask) }
        }
        for (index, draft) in subtasks.enumerated() {
            let newSubtask = HabitSubtask(title: draft.title, displayOrder: index, habit: habit)
            modelContext.insert(newSubtask)
        }
        try? modelContext.save()
    }
    
    func handleNotifications(for habit: Habit) {
        if isReminderEnabled {
            Task {
                if await NotificationManager.shared.ensureAuthorization() {
                    await NotificationManager.shared.scheduleNotifications(for: habit)
                }
            }
        } else {
            NotificationManager.shared.cancelNotifications(for: habit)
        }
    }
}
