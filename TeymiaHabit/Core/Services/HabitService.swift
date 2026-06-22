import SwiftData
import SwiftUI

@Observable @MainActor
final class HabitService {

    // MARK: - Properties
    @ObservationIgnored private var temporaryProgress: [String: Int] = [:]
    @ObservationIgnored private let repository = HabitRepository()
    @ObservationIgnored private let notificationManager: NotificationManager
    @ObservationIgnored private let timerService: TimerService
    @ObservationIgnored private let calendar = Calendar.current

    // MARK: - Init
    init(notificationManager: NotificationManager, timerService: TimerService) {
        self.notificationManager = notificationManager
        self.timerService = timerService
    }

    // MARK: - CRUD

    func createHabit(with config: Habit.Configuration) async {
        let habit = Habit(
            title: config.title,
            type: config.type,
            goal: config.goal,
            iconName: config.iconName,
            iconColor: config.iconColor,
            createdAt: Date(),
            activeDays: config.activeDays,
            reminderTimes: config.reminderTimes,
            startDate: config.startDate,
            source: config.source,
            healthKitMetric: config.healthKitMetric
        )
        repository.create(habit)
        if config.reminderTimes != nil {
            await notificationManager.scheduleNotifications(for: habit)
        }
    }

    func updateHabit(_ habit: Habit, with config: Habit.Configuration) async {
        habit.update(with: config)
        repository.update()
        notificationManager.cancelNotifications(for: habit)
        if config.reminderTimes != nil {
            await notificationManager.scheduleNotifications(for: habit)
        }
    }

    func delete(_ habit: Habit) {
        notificationManager.cancelNotifications(for: habit)
        repository.delete(habit)
    }

    func archive(_ habit: Habit) {
        habit.isArchived = true
        repository.update()
    }

    func unarchive(_ habit: Habit) {
        habit.isArchived = false
        repository.update()
    }

    func reorderHabits(_ habits: [Habit]) {
        for (index, habit) in habits.enumerated() {
            habit.displayOrder = index
        }
        repository.update()
    }

    // MARK: - Read-Only Calculations

    func isHabitActive(_ habit: Habit, on date: Date) -> Bool {
        if calendar.startOfDay(for: date) < calendar.startOfDay(for: habit.startDate) { return false }
        let weekday = Weekday.from(date: date)
        return (habit.activeDaysBitmask & (1 << weekday.rawValue)) != 0
    }

    func progress(for habit: Habit, on date: Date) -> Int {
        repository.fetchProgress(for: habit, on: date)
    }

    func isSkipped(_ habit: Habit, on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return habit.skippedDates.contains { calendar.isDate($0, inSameDayAs: startOfDay) }
    }

    func completionPercentage(for habit: Habit, on date: Date) -> Double {
        guard habit.goal > 0 else {
            return progress(for: habit, on: date) > 0 ? 1.0 : 0.0
        }
        return min(Double(progress(for: habit, on: date)) / Double(habit.goal), 1.0)
    }

    // MARK: - Progress Mutations

    func effectiveProgress(for habit: Habit, on date: Date) -> Int {
        let key = makeKey(for: habit.uuid, date: date)
        if let temp = temporaryProgress[key] { return temp }

        if habit.type == .time && calendar.isDateInToday(date) {
            if let live = timerService.getLiveProgress(for: habit.uuid.uuidString) {
                return live
            }
        }
        return progress(for: habit, on: date)
    }

    @discardableResult
    func addProgress(_ delta: Int, to habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        let before = progress(for: habit, on: targetDate)
        let after = max(0, before + delta)
        return updateProgress(to: after, for: habit, date: targetDate)
    }

    @discardableResult
    func updateProgress(to newValue: Int, for habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        let wasCompleted = progress(for: habit, on: targetDate) >= habit.goal
        repository.saveProgress(newValue, for: habit, on: targetDate)
        return !wasCompleted && (newValue >= habit.goal)
    }

    func resetProgress(for habit: Habit, date: Date) {
        updateProgress(to: 0, for: habit, date: date)
    }

    func saveProgress(_ value: Int, for habit: Habit, date: Date) {
        repository.saveProgress(value, for: habit, on: date)
    }

    @discardableResult
    func completeHabit(for habit: Habit, date: Date) -> Bool {
        let targetDate = calendar.startOfDay(for: date)
        if isSkipped(habit, on: targetDate) {
            unskipDate(targetDate, for: habit)
        }
        return updateProgress(to: habit.goal, for: habit, date: targetDate)
    }

    // MARK: - Temporary Progress (UI cache)

    func setTemporaryProgress(for habitId: UUID, date: Date, progress: Int) {
        temporaryProgress[makeKey(for: habitId, date: date)] = progress
    }

    func getTemporaryProgress(for habitId: UUID, date: Date) -> Int? {
        temporaryProgress[makeKey(for: habitId, date: date)]
    }

    func clearTemporaryProgress(for habitId: UUID, date: Date) {
        temporaryProgress.removeValue(forKey: makeKey(for: habitId, date: date))
    }

    // MARK: - Skip Management

    func skipDate(_ date: Date, for habit: Habit) {
        repository.addSkippedDate(date, for: habit)
    }

    func unskipDate(_ date: Date, for habit: Habit) {
        repository.removeSkippedDate(date, for: habit)
    }

    // MARK: - Private

    private func makeKey(for uuid: UUID, date: Date) -> String {
        "\(uuid.uuidString)_\(calendar.startOfDay(for: date).description)"
    }
}
