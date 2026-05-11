import SwiftUI
import SwiftData

@Observable @MainActor
final class HabitStatisticsViewModel {
    let habit: Habit
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var totalValue: Int = 0
    var selectedDate: Date = Date()
    var barChartTimeRange: ChartTimeRange = .week

    init(habit: Habit) {
        self.habit = habit
        refresh()
    }

    var formattedTotal: String {
        habit.type == .time
        ? totalRawValue.formattedAsLocalizedDuration()
        : "\(totalRawValue)"
    }

    private var totalRawValue: Int {
        (habit.completions ?? []).reduce(0) { $0 + $1.value }
    }

    func refresh() {
        let calendar = Calendar.current
        let goal = habit.goal
        let normalizedDates = (habit.completions ?? [])
            .filter { $0.value >= goal }
            .map { calendar.startOfDay(for: $0.date) }
        let completedSet = Set(normalizedDates)

        self.totalValue = completedSet.count
        self.currentStreak = calculateCurrentStreak(completedSet: completedSet, calendar: calendar)
        self.bestStreak = calculateBestStreak(completedSet: completedSet, calendar: calendar)
    }

    // MARK: - Private Methods

    private func calculateCurrentStreak(completedSet: Set<Date>, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: Date())
        let isCompletedToday = completedSet.contains(today)
        let isSkippedToday = habit.isSkipped(on: today)
        let isActiveToday = habit.isActiveOnDate(today)

        if isActiveToday && !isCompletedToday && !isSkippedToday {
            if calendar.component(.hour, from: Date()) >= 23 {
                return 0
            }
        }

        var streak = 0
        var currentDate: Date = (isCompletedToday || isSkippedToday)
            ? today
            : calendar.date(byAdding: .day, value: -1, to: today) ?? today

        let startLimit = calendar.startOfDay(for: habit.startDate)

        while currentDate >= startLimit {
            let isActive = habit.isActiveOnDate(currentDate)

            if !isActive {
                guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = nextDate
                continue
            }

            let isCompleted = completedSet.contains(currentDate)
            let isSkipped = habit.isSkipped(on: currentDate)

            if isCompleted || isSkipped {
                streak += 1
                guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = nextDate
            } else {
                break
            }
        }

        return streak
    }

    private func calculateBestStreak(completedSet: Set<Date>, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: Date())
        var bestStreak = 0
        var currentStreak = 0
        var checkDate = calendar.startOfDay(for: habit.startDate)

        while checkDate <= today {
            if habit.isActiveOnDate(checkDate) {
                let isCompleted = completedSet.contains(checkDate)
                let isSkipped = habit.isSkipped(on: checkDate)

                if isCompleted || isSkipped {
                    currentStreak += 1
                    bestStreak = max(bestStreak, currentStreak)
                } else {
                    currentStreak = 0
                }
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: checkDate) else { break }
            checkDate = nextDate
        }

        return bestStreak
    }
}

