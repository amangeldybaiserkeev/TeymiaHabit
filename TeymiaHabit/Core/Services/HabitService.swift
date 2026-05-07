import Foundation
import SwiftData

@Observable @MainActor
final class HabitService {
    var temporaryProgress: [String: Int] = [:]

    private let modelContext: ModelContext
    private let widgetService: WidgetService
    private let notificationManager: NotificationManager
    private let timerService: TimerService
    private let calendar = Calendar.current

    init(
        modelContext: ModelContext,
        widgetService: WidgetService,
        notificationManager: NotificationManager,
        timerService: TimerService
    ) {
        self.modelContext = modelContext
        self.widgetService = widgetService
        self.notificationManager = notificationManager
        self.timerService = timerService
    }

    func createHabit(with config: Habit.Configuration) {
        let habit = Habit(
            title: config.title,
            type: config.type,
            goal: config.goal,
            iconName: config.iconName,
            iconColor: config.iconColor,
            createdAt: Date(),
            activeDays: config.activeDays,
            reminderTimes: config.reminderTimes,
            startDate: config.startDate
        )

        modelContext.insert(habit)
        saveAndRefresh()
        handleNotifications(for: habit, isReminderEnabled: config.reminderTimes != nil)
    }

    func updateHabit(_ habit: Habit, with config: Habit.Configuration) {
        habit.update(with: config)
        saveAndRefresh()
        handleNotifications(for: habit, isReminderEnabled: config.reminderTimes != nil)
    }

    // MARK: - CRUD

    func resetProgress(for habit: Habit, date: Date) {
        updateProgress(to: 0, for: habit, date: date)
    }

    // MARK: - Progress

    func effectiveProgress(for habit: Habit, on date: Date) -> Int {
        let key = makeKey(for: habit.uuid, date: date)
        if let temp = temporaryProgress[key] {
            return temp
        }

        if habit.type == .time && calendar.isDateInToday(date) {
            if let live = timerService.getLiveProgress(for: habit.uuid.uuidString) {
                 return live
            }
        }

        return habit.progressForDate(date)
    }

    func setTemporaryProgress(for habitId: UUID, date: Date, progress: Int) {
        let key = makeKey(for: habitId, date: date)
        temporaryProgress[key] = progress
    }

    func getTemporaryProgress(for habitId: UUID, date: Date) -> Int? {
        let key = makeKey(for: habitId, date: date)
        return temporaryProgress[key]
    }

    func clearTemporaryProgress(for habitId: UUID, date: Date) {
        let key = makeKey(for: habitId, date: date)
        temporaryProgress.removeValue(forKey: key)
    }

    @discardableResult
    func completeHabit(for habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        let isCurrentlyCompleted = habit.progressForDate(targetDate) >= habit.goal

        if habit.isSkipped(on: targetDate) {
            unskipDate(targetDate, for: habit)
        }

        let newProgress = isCurrentlyCompleted ? 0 : habit.goal
        return updateProgress(to: newProgress, for: habit, date: targetDate)
    }

    @discardableResult
    func updateProgress(to newValue: Int, for habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        let wasCompleted = habit.progressForDate(targetDate) >= habit.goal

        habit.completions?
            .filter { calendar.isDate($0.date, inSameDayAs: targetDate) }
            .forEach { modelContext.delete($0) }

        if newValue > 0 {
            let newCompletion = HabitCompletion(date: targetDate, value: newValue, habit: habit)
            modelContext.insert(newCompletion)
        }

        saveAndRefresh()
        return !wasCompleted && (newValue >= habit.goal)
    }

    @discardableResult
    func addProgress(_ delta: Int, to habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        let before = habit.progressForDate(targetDate)
        let after = max(0, before + delta)

        return updateProgress(to: after, for: habit, date: targetDate)
    }

    func saveProgress(_ value: Int, for habit: Habit, date: Date) {
        let targetDate = calendar.startOfDay(for: date)
        let existing = habit.completions?.first { calendar.isDate($0.date, inSameDayAs: targetDate) }

        if let existing {
            if value > 0 {
                if existing.value != value { existing.value = value }
            } else {
                modelContext.delete(existing)
            }
        } else if value > 0 {
            let completion = HabitCompletion(date: targetDate, value: value, habit: habit)
            modelContext.insert(completion)
        }

        saveAndRefresh()
    }

    // MARK: - Skip Management

    func skipDate(_ date: Date, for habit: Habit) {
        let targetDate = calendar.startOfDay(for: date)
        var currentSkips = habit.skippedDates

        guard !currentSkips.contains(where: { calendar.isDate($0, inSameDayAs: targetDate) }) else { return }

        currentSkips.append(targetDate)
        habit.skippedDates = currentSkips
        saveAndRefresh()
    }

    func unskipDate(_ date: Date, for habit: Habit) {
        let targetDate = calendar.startOfDay(for: date)

        habit.skippedDates.removeAll { calendar.isDate($0, inSameDayAs: targetDate) }
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

    private func saveAndRefresh() {
        widgetService.reloadWidgetsAfterDataChange()

        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            try? self.modelContext.save()
        }
    }

    private func makeKey(for uuid: UUID, date: Date) -> String {
        let dateString = calendar.startOfDay(for: date).description
        return "\(uuid.uuidString)_\(dateString)"
    }

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
