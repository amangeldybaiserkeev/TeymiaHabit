import Foundation
import SwiftUI

@Observable @MainActor
final class HabitDetailViewModel {

    // MARK: - Dependencies
    private let habitService: HabitService
    private let timerService: TimerService
    private let notificationManager: NotificationManager
    private let soundManager: SoundManager

    private let habit: Habit
    private let cachedHabitId: String

    // MARK: - Timer / Save debounce
    private var saveTask: Task<Void, Never>?
    private var goalSoundPlayed = false
    private var goalNotificationSent = false

    // MARK: - Displayed date
    private(set) var currentDisplayedDate: Date

    // MARK: - Init
    init(
        habit: Habit,
        initialDate: Date,
        habitService: HabitService,
        timerService: TimerService,
        notificationManager: NotificationManager,
        soundManager: SoundManager
    ) {
        self.habit = habit
        self.currentDisplayedDate = initialDate
        self.cachedHabitId = habit.uuid.uuidString
        self.habitService = habitService
        self.timerService = timerService
        self.notificationManager = notificationManager
        self.soundManager = soundManager
    }

    // MARK: - Computed Properties

    var title: String { habit.title }
    var iconName: String { habit.iconName }
    var ringColors: (dark: Color, light: Color) { habit.ringColors }
    var formattedGoal: String { habit.formattedGoal }

    var isTimerRunning: Bool { timerService.isTimerRunning(for: cachedHabitId) }
    var timerStartTime: Date? { timerService.getTimerStartTime(for: cachedHabitId) }

    private var isToday: Bool { Calendar.current.isDateInToday(currentDisplayedDate) }
    private var isTimeHabitToday: Bool { habit.type == .time && isToday }

    var currentProgress: Int {
        _ = timerService.updateTrigger
        return habitService.effectiveProgress(for: habit, on: currentDisplayedDate)
    }

    var completionPercentage: Double {
        habitService.completionPercentage(for: habit, on: currentDisplayedDate)
    }

    var isAlreadyCompleted: Bool { currentProgress >= habit.goal }

    var isSkipped: Bool {
        habitService.isSkipped(habit, on: currentDisplayedDate)
    }

    // MARK: - Date Management

    func updateDisplayedDate(_ newDate: Date) {
        currentDisplayedDate = newDate
        habitService.clearTemporaryProgress(for: habit.uuid, date: newDate)
        goalSoundPlayed = false
        goalNotificationSent = false
    }

    // MARK: - Goal Progress

    func checkGoalProgress(_ current: Int) {
        guard current >= habit.goal, !goalSoundPlayed else { return }
        goalSoundPlayed = true
        soundManager.playCompletionSound()

        if !goalNotificationSent {
            goalNotificationSent = true
            Task { await notificationManager.sendGoalAchievedNotification(for: habit) }
        }
    }

    // MARK: - Progress Actions

    func incrementProgress() {
        stopTimerIfNeeded()
        let step = habit.type == .count ? 1 : 60
        let maxVal = habit.type == .count ? 999_999 : 86_400
        let new = min(currentProgress + step, maxVal)
        habitService.setTemporaryProgress(for: habit.uuid, date: currentDisplayedDate, progress: new)
        saveProgress(new)
        checkGoalProgress(new)
    }

    func decrementProgress() {
        stopTimerIfNeeded()
        let step = habit.type == .count ? 1 : 60
        let new = max(currentProgress - step, 0)
        habitService.setTemporaryProgress(for: habit.uuid, date: currentDisplayedDate, progress: new)
        saveProgress(new)
    }

    func resetProgress() {
        habitService.setTemporaryProgress(for: habit.uuid, date: currentDisplayedDate, progress: 0)
        habitService.resetProgress(for: habit, date: currentDisplayedDate)
        goalSoundPlayed = false
        goalNotificationSent = false
    }

    func completeHabit() {
        guard !isAlreadyCompleted else { return }
        habitService.setTemporaryProgress(for: habit.uuid, date: currentDisplayedDate, progress: habit.goal)
        saveProgress(habit.goal)
        checkGoalProgress(habit.goal)
    }

    func addProgress(_ value: Int) {
        let maxValue = habit.type == .count ? 999_999 : 86_400
        let new = min(currentProgress + value, maxValue)
        habitService.setTemporaryProgress(for: habit.uuid, date: currentDisplayedDate, progress: new)
        saveProgress(new)
        checkGoalProgress(new)
    }

    // MARK: - Timer Actions

    func toggleTimer() {
        guard isTimeHabitToday else { return }
        isTimerRunning ? stopTimer() : startTimer()
    }

    private func startTimer() {
        let base = habitService.progress(for: habit, on: currentDisplayedDate)
        goalSoundPlayed = false
        goalNotificationSent = false
        timerService.startTimer(for: cachedHabitId, baseProgress: base)
    }

    private func stopTimer() {
        guard let final = timerService.stopTimer(for: cachedHabitId) else { return }
        saveProgress(final)
        checkGoalProgress(final)
    }

    // MARK: - Actions

    func toggleSkip() {
        if isSkipped {
            habitService.unskipDate(currentDisplayedDate, for: habit)
        } else {
            stopTimerIfNeeded()
            habitService.skipDate(currentDisplayedDate, for: habit)
        }
    }

    func archiveHabit() {
        stopTimerIfNeeded()
        habitService.archive(habit)
    }

    func deleteHabit() {
        stopTimerIfNeeded()
        prepareForDeletion()
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            habitService.delete(habit)
        }
    }

    func prepareForDeletion() {
        saveTask?.cancel()
    }

    // MARK: - Private

    private func saveProgress(_ value: Int) {
        let dateAtMomentOfSave = currentDisplayedDate
        habitService.saveProgress(value, for: habit, date: dateAtMomentOfSave)

        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(0.8))
            guard !Task.isCancelled else { return }
            habitService.clearTemporaryProgress(for: habit.uuid, date: dateAtMomentOfSave)
        }
    }

    private func stopTimerIfNeeded() {
        guard isTimerRunning else { return }
        stopTimer()
    }
}
