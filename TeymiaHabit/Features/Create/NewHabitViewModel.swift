import SwiftUI

@Observable @MainActor
final class NewHabitViewModel {
    private let habitService: any HabitServiceProtocol

    let habit: Habit?
    var title = ""
    var selectedType: HabitType = .count
    var goalConfig = GoalConfiguration()
    var activeDays: [Bool] = Array(repeating: true, count: 7)
    var isReminderEnabled = false
    var reminderTimes: [Date] = [Date()]
    var startDate = Date()
    var selectedIcon = "book.fill"
    var selectedIconColor: HabitIconColor = .primary

    // MARK: - Init
    init(habitService: any HabitServiceProtocol, habit: Habit?) {
        self.habitService = habitService
        self.habit = habit

        if let habit {
            loadValues(from: habit)
        }
        self.initialSnapshot = makeSnapshot()
    }

    private enum Constants {
        static let secondsInHour = 3600
        static let secondsInMinute = 60
        static let maxSecondsInDay = 86_400
        static let maxCount = 999_999
    }

    // MARK: - Computed UI Properties
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
            return !title.isEmpty || isReminderEnabled || selectedType != .count
        }
        return initial != makeSnapshot()
    }

    // MARK: - Private State
    private var initialSnapshot: Snapshot?

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

    // MARK: - Actions
    func save() {
        guard isFormValid else { return }

        let config = Habit.Configuration(
            title: title,
            type: selectedType,
            goal: effectiveGoal,
            iconName: selectedIcon,
            iconColor: selectedIconColor,
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
            iconColor: selectedIconColor
        )
    }
}

