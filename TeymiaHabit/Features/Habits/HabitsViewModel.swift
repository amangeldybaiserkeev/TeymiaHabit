import SwiftUI

@Observable @MainActor
final class HabitsViewModel {

    // MARK: - Dependencies
    private let habitService: HabitService
    private let soundManager: SoundManager
    let timerService: TimerService

    // MARK: - Init
    init(habitService: HabitService, soundManager: SoundManager, timerService: TimerService) {
        self.habitService = habitService
        self.soundManager = soundManager
        self.timerService = timerService
    }

    // MARK: - Public Methods

    func isHabitSkipped(_ habit: Habit, on date: Date) -> Bool {
        habitService.isSkipped(habit, on: date)
    }

    // MARK: - Actions

    func getEffectiveProgress(for habit: Habit, on date: Date) -> Int {
        habitService.effectiveProgress(for: habit, on: date)
    }

    func handleRingTap(on habit: Habit, date: Date) {
        switch habit.type {
        case .count:
            let current = habitService.getTemporaryProgress(for: habit.uuid, date: date) ?? habit.progressForDate(date)
            habitService.setTemporaryProgress(for: habit.uuid, date: date, progress: current + 1)
            let didComplete = habitService.addProgress(1, to: habit, date: date)
            if didComplete { soundManager.playCompletionSound() }

        case .time:
            let habitId = habit.uuid.uuidString
            if timerService.isTimerRunning(for: habitId) {
                if let finalProgress = timerService.stopTimer(for: habitId) {
                    habitService.setTemporaryProgress(for: habit.uuid, date: date, progress: finalProgress)
                    let didComplete = habitService.updateProgress(to: finalProgress, for: habit, date: date)
                    if didComplete { soundManager.playCompletionSound() }
                }
            } else {
                let current = habit.progressForDate(date)
                timerService.startTimer(for: habitId, baseProgress: current)
            }
        }

        saveAndClearWithDebounce(for: habit.uuid, date: date)
    }

    func completeHabit(_ habit: Habit, date: Date) {
        habitService.completeHabit(for: habit, date: date)
    }

    func toggleSkip(for habit: Habit, date: Date) {
        if habit.isSkipped(on: date) {
            habitService.unskipDate(date, for: habit)
        } else {
            habitService.skipDate(date, for: habit)
        }
    }

    func archiveHabit(_ habit: Habit) {
        habitService.archive(habit)
    }

    func deleteHabit(_ habit: Habit) {
        habitService.delete(habit)
    }

    // MARK: - Timer

    func checkCompletionForActiveTimer(_ habit: Habit, date: Date) {
        guard let liveProgress = timerService.getLiveProgress(for: habit.uuid.uuidString),
              habit.progressForDate(date) < habit.goal,
              liveProgress >= habit.goal else { return }
        soundManager.playCompletionSound()
    }

    // MARK: - Private

    private func saveAndClearWithDebounce(for uuid: UUID, date: Date) {
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            habitService.clearTemporaryProgress(for: uuid, date: date)
        }
    }
}
