import Foundation
import ActivityKit

@Observable @MainActor
final class TimerService {

    private var activeTimers: [String: TimerData] = [:]
    private var uiTimer: Timer?
    private(set) var updateTrigger: Int = 0

    private struct TimerData {
        let habitId: String
        let startTime: Date
        let baseProgress: Int
    }

    // MARK: - Public

    func isTimerRunning(for habitId: String) -> Bool {
        activeTimers[habitId] != nil
    }

    func getLiveProgress(for habitId: String) -> Int? {
        guard let timerData = activeTimers[habitId] else { return nil }
        let elapsed = Int(Date().timeIntervalSince(timerData.startTime))
        return timerData.baseProgress + elapsed
    }

    func startTimer(for habitId: String, baseProgress: Int) {
        guard activeTimers[habitId] == nil else { return }

        activeTimers[habitId] = TimerData(
            habitId: habitId,
            startTime: Date(),
            baseProgress: baseProgress
        )

        if uiTimer == nil {
            startUITimer()
        }

        triggerUIUpdate()
    }

    @discardableResult
    func stopTimer(for habitId: String) -> Int? {
        guard let timerData = activeTimers[habitId] else { return nil }

        let elapsed = Int(Date().timeIntervalSince(timerData.startTime))
        let finalProgress = min(timerData.baseProgress + elapsed, 86400)

        activeTimers.removeValue(forKey: habitId)

        if activeTimers.isEmpty {
            stopUITimer()
        }

        triggerUIUpdate()
        return finalProgress
    }

    func getTimerStartTime(for habitId: String) -> Date? {
        activeTimers[habitId]?.startTime
    }

    // MARK: - App Lifecycle

    func handleAppDidEnterBackground() {
        // Background handling for Live Activities - timers continue running
    }

    func handleAppWillEnterForeground() {
        if !activeTimers.isEmpty && uiTimer == nil {
            startUITimer()
        }

        triggerUIUpdate()
    }

    /// Check if any timers are from previous day and clean them up
    func cleanupStaleTimers() {
        let calendar = Calendar.current
        let now = Date()
        var staleTimers: [String] = []

        for (habitId, timerData) in activeTimers where !calendar.isDate(timerData.startTime, inSameDayAs: now) {
            staleTimers.append(habitId)
        }

        for habitId in staleTimers {
            activeTimers.removeValue(forKey: habitId)
        }

        if activeTimers.isEmpty && uiTimer != nil {
            stopUITimer()
        }

        if !staleTimers.isEmpty {
            triggerUIUpdate()
        }
    }

    // MARK: - Private Methods

    private func startUITimer() {
        uiTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTrigger += 1
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        timer.tolerance = 0.1
        uiTimer = timer
    }

    private func stopUITimer() {
        uiTimer?.invalidate()
        uiTimer = nil
    }

    func triggerUIUpdate() {
        updateTrigger += 1
    }
}
