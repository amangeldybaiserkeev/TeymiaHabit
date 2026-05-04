import SwiftUI

// MARK: - Goal Configuration

struct GoalConfiguration {
    // Single source of truth for count: the raw text the user types.
    // countGoal is derived from countText, not stored separately.
    var countText: String = "1"
    var hours: Int = 0
    var minutes: Int = 0

    /// Parsed count value. Returns nil if the text is not a valid positive integer.
    var parsedCount: Int? {
        guard let value = Int(countText), value > 0 else { return nil }
        return value
    }
}

// MARK: - ViewModel

@Observable @MainActor
final class NewHabitViewModel {

    // HabitService owns modelContext, widgetService, and notificationManager.
    // ViewModel delegates all persistence and side effects to it.
    private let habitService: HabitService

    private enum Constants {
        static let secondsInHour   = 3600
        static let secondsInMinute = 60
        static let maxSecondsInDay = 86_400
        static let maxCount        = 999_999
    }

    // The habit being edited, nil when creating a new one.
    let habit: Habit?

    // MARK: - Form State

    var title             = ""
    var selectedType: HabitType    = .count
    var goalConfig        = GoalConfiguration()
    var activeDays: [Bool]         = Array(repeating: true, count: 7)
    var isReminderEnabled = false
    var reminderTimes: [Date]      = [Date()]
    var startDate         = Date()
    var selectedIcon      = "book.fill"
    var selectedIconColor: HabitIconColor = .primary
    var selectedHexColor: String?  = nil

    // MARK: - Computed UI Properties

    var actualColor: Color {
        if let hex = selectedHexColor { return Color(hex: hex) }
        return selectedIconColor.baseColor
    }

    var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let hasGoal: Bool = switch selectedType {
        case .count: goalConfig.parsedCount != nil
        case .time: goalConfig.hours > 0 || goalConfig.minutes > 0
        }
        return hasTitle && hasGoal
    }

    var hasChanges: Bool {
        guard let initial = initialSnapshot else {
            // New habit: any non-default input counts as a change
            return !title.isEmpty || isReminderEnabled || selectedType != .count
        }
        return initial != makeSnapshot()
    }

    // MARK: - Private State

    private var initialSnapshot: Snapshot?

    /// Effective goal value in the model's unit (count or seconds).
    /// Clamped to safe ranges to prevent corrupt data.
    private var effectiveGoal: Int {
        switch selectedType {
        case .count:
            let value = goalConfig.parsedCount ?? 1
            return min(value, Constants.maxCount)
        case .time:
            let total = goalConfig.hours * Constants.secondsInHour
                      + goalConfig.minutes * Constants.secondsInMinute
            return min(total, Constants.maxSecondsInDay)
        }
    }

    // MARK: - Init

    init(habitService: HabitService, habit: Habit? = nil) {
        self.habitService = habitService
        self.habit = habit

        if let habit {
            loadValues(from: habit)
        }
        self.initialSnapshot = makeSnapshot()
    }

    // MARK: - Actions

    /// Persists the habit. View calls this and then dismisses itself.
    func save() {
        guard isFormValid else { return }

        let config = Habit.Configuration(
            title: title,
            type: selectedType,
            goal: effectiveGoal,
            iconName: selectedIcon,
            iconColor: selectedIconColor,
            hexColor: selectedHexColor,
            activeDays: activeDays,
            reminderTimes: isReminderEnabled ? reminderTimes : nil,
            startDate: startDate
        )

        if let existing = habit {
            habitService.updateHabit(existing, with: config)
        } else {
            habitService.createHabit(with: config)
        }
    }

    // MARK: - Private Helpers

    private func loadValues(from habit: Habit) {
        title             = habit.title
        selectedType      = habit.type
        activeDays        = habit.activeDays
        startDate         = habit.startDate
        selectedIcon      = habit.iconName
        selectedIconColor = habit.iconColor
        selectedHexColor  = habit.hexColor
        isReminderEnabled = habit.reminderTimes?.isEmpty == false
        reminderTimes     = habit.reminderTimes ?? [Date()]

        switch habit.type {
        case .count:
            goalConfig.countText = String(habit.goal)
        case .time:
            goalConfig.hours   = habit.goal / Constants.secondsInHour
            goalConfig.minutes = (habit.goal % Constants.secondsInHour) / Constants.secondsInMinute
        }
    }

    // MARK: - Snapshot

    // Snapshot captures every user-editable field so hasChanges is accurate.
    // Previously missing: reminderTimes, startDate, iconColor.
    private struct Snapshot: Equatable {
        let title: String
        let type: HabitType
        let goal: Int
        let activeDays: [Bool]
        let isReminderEnabled: Bool
        let reminderTimes: [Date]
        let startDate: Date
        let iconName: String
        let iconColor: HabitIconColor
        let hexColor: String?
    }

    private func makeSnapshot() -> Snapshot {
        Snapshot(
            title: title,
            type: selectedType,
            goal: effectiveGoal,
            activeDays: activeDays,
            isReminderEnabled: isReminderEnabled,
            reminderTimes: reminderTimes,
            startDate: startDate,
            iconName: selectedIcon,
            iconColor: selectedIconColor,
            hexColor: selectedHexColor
        )
    }
}

