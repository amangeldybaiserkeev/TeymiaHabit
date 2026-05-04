import Foundation
import SwiftData

@Observable @MainActor
final class HabitService {
    private let modelContext: ModelContext
    private let widgetService: WidgetService
    private let notificationManager: NotificationManager

    init(
        modelContext: ModelContext,
        widgetService: WidgetService,
        notificationManager: NotificationManager
    ) {
        self.modelContext = modelContext
        self.widgetService = widgetService
        self.notificationManager = notificationManager
    }

    // MARK: - CRUD

    /// Creates a new habit and schedules notifications if needed.
    /// Notifications are scheduled after save to ensure the habit is persisted first.
    func createHabit(with config: Habit.Configuration) {
        let habit = Habit(
            title: config.title,
            type: config.type,
            goal: config.goal,
            iconName: config.iconName,
            iconColor: config.iconColor,
            hexColor: config.hexColor,
            createdAt: Date(),
            activeDays: config.activeDays,
            reminderTimes: config.reminderTimes,
            startDate: config.startDate
        )

        modelContext.insert(habit)
        saveAndRefresh()
        handleNotifications(for: habit, isReminderEnabled: config.reminderTimes != nil)
    }

    /// Updates an existing habit and reschedules notifications.
    func updateHabit(_ habit: Habit, with config: Habit.Configuration) {
        habit.update(with: config)

        saveAndRefresh()
        handleNotifications(for: habit, isReminderEnabled: config.reminderTimes != nil)
    }

    // MARK: - Progress Management

    @discardableResult
    func completeHabit(for habit: Habit, date: Date) -> Bool {
        let isCurrentlyCompleted = habit.progressForDate(date) >= habit.goal

        if habit.isSkipped(on: date) {
            unskipDate(date, for: habit)
        }

        if isCurrentlyCompleted {
            updateProgress(to: 0, for: habit, date: date)
            return false
        } else {
            updateProgress(to: habit.goal, for: habit, date: date)
            return true
        }
    }

    func resetProgress(for habit: Habit, date: Date) {
        updateProgress(to: 0, for: habit, date: date)
    }

    @discardableResult
    func updateProgress(to newValue: Int, for habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let wasCompleted = habit.progressForDate(targetDate) >= habit.goal

        let existingCompletions = habit.completions?.filter {
            calendar.isDate($0.date, inSameDayAs: targetDate)
        } ?? []
        existingCompletions.forEach { modelContext.delete($0) }

        if newValue > 0 {
            let newCompletion = HabitCompletion(date: targetDate, value: newValue, habit: habit)
            modelContext.insert(newCompletion)
        }

        saveAndRefresh()

        let isCompletedNow = newValue >= habit.goal
        return !wasCompleted && isCompletedNow
    }

    @discardableResult
    func addProgress(_ delta: Int, to habit: Habit, date: Date) -> Bool {
        let before = habit.progressForDate(date)
        let after = max(0, before + delta)
        updateProgress(to: after, for: habit, date: date)
        return before < habit.goal && after >= habit.goal
    }

    func saveProgress(_ value: Int, for habit: Habit, date: Date) {
        let calendar = Calendar.current
        let existingCompletions = habit.completions?.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        } ?? []

        if let existing = existingCompletions.first {
            if value > 0 {
                existing.value = value
            } else {
                modelContext.delete(existing)
            }
        } else if value > 0 {
            let completion = HabitCompletion(date: date, value: value, habit: habit)
            modelContext.insert(completion)
        }

        saveAndRefresh()
    }

    // MARK: - Skip Management

    func skipDate(_ date: Date, for habit: Habit) {
        let targetDate = Calendar.current.startOfDay(for: date)
        var currentSkips = habit.skippedDates

        guard !currentSkips.contains(where: {
            Calendar.current.isDate($0, inSameDayAs: targetDate)
        }) else { return }

        currentSkips.append(targetDate)
        habit.skippedDates = currentSkips
        saveAndRefresh()
    }

    func unskipDate(_ date: Date, for habit: Habit) {
        let targetDate = Calendar.current.startOfDay(for: date)
        var currentSkips = habit.skippedDates

        currentSkips.removeAll {
            Calendar.current.isDate($0, inSameDayAs: targetDate)
        }
        habit.skippedDates = currentSkips
        saveAndRefresh()
    }

    // MARK: - Lifecycle Management

    func archive(_ habit: Habit) {
        habit.isArchived = true
        saveAndRefresh()
    }

    func unarchive(_ habit: Habit) {
        habit.isArchived = false
        saveAndRefresh()
    }

    func delete(_ habit: Habit) {
        notificationManager.cancelNotifications(for: habit)
        modelContext.delete(habit)
        saveAndRefresh()
    }

    // MARK: - Private Helpers

    private var saveTask: Task<Void, Never>?

    /// Debounced save: waits 500ms and cancels if another save comes in sooner.
    /// Widgets are reloaded immediately since they read from shared App Group storage.
    private func saveAndRefresh() {
        widgetService.reloadWidgetsAfterDataChange()

        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            try? self.modelContext.save()
        }
    }

    /// Handles notification scheduling after a habit is persisted.
    /// The Task is fire-and-forget here intentionally: notification failure is non-fatal
    /// and the UI doesn't need to wait for it. The Task captures self weakly to avoid
    /// a retain cycle if the service is deallocated (unlikely for a singleton, but correct).
    private func handleNotifications(for habit: Habit, isReminderEnabled: Bool) {
        guard isReminderEnabled else {
            notificationManager.cancelNotifications(for: habit)
            return
        }
        Task { [weak self] in
            guard let self else { return }
            _ = await self.notificationManager.scheduleNotifications(for: habit)
        }
    }
}
