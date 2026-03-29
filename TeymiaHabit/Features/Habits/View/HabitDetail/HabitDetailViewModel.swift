import SwiftUI
import SwiftData

@Observable @MainActor
final class HabitDetailViewModel {
    
    // MARK: - Dependencies
    private let habit: Habit
    private let modelContext: ModelContext
    private let cachedHabitId: String
    
    // MARK: - Timer / Save debounce
    private var saveTask: Task<Void, Never>?
    private var goalSoundPlayed = false
    private var goalNotificationSent = false
    
    // MARK: - UI State
    var alertState = AlertState()
    var onHabitDeleted: (() -> Void)?
    var onDataSaved: (() -> Void)?
    
    // MARK: - Displayed date
    private(set) var currentDisplayedDate: Date
    
    // MARK: - Computed
    
    var isSkipped: Bool { habit.isSkipped(on: currentDisplayedDate) }
    var isTimerRunning: Bool { TimerService.shared.isTimerRunning(for: cachedHabitId) }
    var canStartTimer: Bool { TimerService.shared.canStartNewTimer || isTimerRunning }
    var timerStartTime: Date? { TimerService.shared.getTimerStartTime(for: cachedHabitId) }
    var formattedGoal: String { habit.formattedGoal }
    var hasActiveLiveActivity: Bool { HabitLiveActivityManager.shared.hasActiveActivity(for: cachedHabitId) }
    
    private var isToday: Bool { Calendar.current.isDateInToday(currentDisplayedDate) }
    private var isTimeHabitToday: Bool { habit.type == .time && isToday }
    
    var currentProgress: Int {
        _ = TimerService.shared.updateTrigger
        if isTimeHabitToday, let live = TimerService.shared.getLiveProgress(for: cachedHabitId) {
            return live
        }
        return habit.progressForDate(currentDisplayedDate)
    }
    
    var completionPercentage: Double {
        habit.goal > 0 ? Double(currentProgress) / Double(habit.goal) : 0
    }
    
    var isAlreadyCompleted: Bool { currentProgress >= habit.goal }
    
    // MARK: - Init
    
    init(habit: Habit, initialDate: Date, modelContext: ModelContext) {
        self.habit = habit
        self.currentDisplayedDate = initialDate
        self.modelContext = modelContext
        self.cachedHabitId = habit.uuid.uuidString
    }
    
    // MARK: - Date
    
    func updateDisplayedDate(_ newDate: Date) {
        currentDisplayedDate = newDate
        goalSoundPlayed = false
        goalNotificationSent = false
    }
    
    // MARK: - Goal check (вызывается из View через onChange)
    
    func checkGoalProgress(_ current: Int) {
        guard current >= habit.goal, !goalSoundPlayed else { return }
        goalSoundPlayed = true
        SoundManager.shared.playCompletionSound()
        HapticManager.shared.play(.success)
        
        if !goalNotificationSent {
            goalNotificationSent = true
            Task { await NotificationManager.shared.sendGoalAchievedNotification(for: habit) }
        }
    }
    
    // MARK: - Progress mutations
    
    func incrementProgress() {
        stopTimerIfNeeded()
        let step = habit.type == .count ? 1 : 60
        let max = habit.type == .count ? 999_999 : 86_400
        let current = habit.progressForDate(currentDisplayedDate)
        let new = min(current + step, max)
        saveProgress(new)
        updateLiveActivityIfNeeded(progress: new, timerRunning: false)
    }
    
    func decrementProgress() {
        let current = habit.progressForDate(currentDisplayedDate)
        guard current > 0 else { alertState.errorFeedbackTrigger.toggle(); return }
        stopTimerIfNeeded()
        let step = habit.type == .count ? 1 : 60
        let new = max(current - step, 0)
        saveProgress(new)
        updateLiveActivityIfNeeded(progress: new, timerRunning: false)
    }
    
    func completeHabit() {
        guard !isAlreadyCompleted else { return }
        if isSkipped { habit.unskipDate(currentDisplayedDate, modelContext: modelContext) }
        stopTimerAndEndActivity()
        habit.updateProgress(to: habit.goal, for: currentDisplayedDate, modelContext: modelContext)
        saveTask?.cancel()
        alertState.successFeedbackTrigger.toggle()
        SoundManager.shared.playCompletionSound()
        WidgetUpdateService.shared.reloadWidgetsAfterDataChange()
        onDataSaved?()
    }
    
    func resetProgress() {
        stopTimerAndEndActivity()
        habit.updateProgress(to: 0, for: currentDisplayedDate, modelContext: modelContext)
        saveTask?.cancel()
        updateLiveActivityIfNeeded(progress: 0, timerRunning: false)
        WidgetUpdateService.shared.reloadWidgetsAfterDataChange()
        onDataSaved?()
    }
    
    // MARK: - Timer
    
    func toggleTimer() {
        guard isTimeHabitToday else { return }
        isTimerRunning ? stopTimer() : startTimer()
    }
    
    private func startTimer() {
        guard TimerService.shared.canStartNewTimer else {
            alertState.errorFeedbackTrigger.toggle()
            return
        }
        let base = habit.progressForDate(currentDisplayedDate)
        goalSoundPlayed = false
        goalNotificationSent = false
        
        let ok = TimerService.shared.startTimer(for: cachedHabitId, baseProgress: base)
        guard ok else { alertState.errorFeedbackTrigger.toggle(); return }
        
        Task {
            guard let start = timerStartTime else { return }
            await HabitLiveActivityManager.shared.startActivity(for: habit, currentProgress: base, timerStartTime: start)
        }
    }
    
    private func stopTimer() {
        guard let final = TimerService.shared.stopTimer(for: cachedHabitId) else { return }
        saveProgress(final)
        Task {
            await HabitLiveActivityManager.shared.updateActivity(
                for: cachedHabitId, currentProgress: final,
                isTimerRunning: false, timerStartTime: nil
            )
        }
    }
    
    // MARK: - Skip
    
    func toggleSkip() { isSkipped ? unskipHabit() : skipHabit() }
    
    func skipHabit() {
        habit.skipDate(currentDisplayedDate, modelContext: modelContext)
        alertState.successFeedbackTrigger = true
        WidgetUpdateService.shared.reloadWidgets()
    }
    
    func unskipHabit() {
        habit.unskipDate(currentDisplayedDate, modelContext: modelContext)
        alertState.successFeedbackTrigger = true
        WidgetUpdateService.shared.reloadWidgets()
    }
    
    // MARK: - Cleanup
    
    func prepareForDeletion() {
        saveTask?.cancel()
    }
    
    // MARK: - Private helpers
    
    /// Дебаунс сохранения: ждём 0.8с после последнего изменения
    private func saveProgress(_ value: Int) {
        // Optimistic update через модель
        habit.updateProgress(to: value, for: currentDisplayedDate, modelContext: modelContext)
        
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(0.8))
            guard !Task.isCancelled else { return }
            try? modelContext.save()
            WidgetUpdateService.shared.reloadWidgetsAfterDataChange()
            onDataSaved?()
        }
    }
    
    private func stopTimerIfNeeded() {
        guard isTimerRunning else { return }
        stopTimer()
    }
    
    private func stopTimerAndEndActivity() {
        _ = TimerService.shared.stopTimer(for: cachedHabitId)
        Task { await HabitLiveActivityManager.shared.endActivity(for: cachedHabitId) }
    }
    
    private func updateLiveActivityIfNeeded(progress: Int, timerRunning: Bool) {
        guard isTimeHabitToday, hasActiveLiveActivity else { return }
        Task {
            await HabitLiveActivityManager.shared.updateActivity(
                for: cachedHabitId, currentProgress: progress,
                isTimerRunning: timerRunning, timerStartTime: timerRunning ? timerStartTime : nil
            )
        }
    }
}
