import Foundation

@Observable @MainActor
final class MonthlyCalendarViewModel {
    // MARK: - State
    var months: [Date] = []
    var currentMonthIndex: Int = 0
    var monthCalendarCache: [Int: [[Date?]]] = [:]
    var progressCache: [Date: Double] = [:]
    var detailSheetDate: Date? = nil

    // MARK: - Dependencies
    let habit: Habit
    private let calendar = Calendar.current

    // MARK: - Initialization
    init(habit: Habit) {
        self.habit = habit
    }

    // MARK: - Public Methods

    func setup(selectedDate: Date) {
        generateMonths()
        let index = findMonthIndex(for: selectedDate)
        if let index {
            currentMonthIndex = index
        }
        prepareInitialData()
    }

    func updateMonthIfNeeded(for newDate: Date) {
        if let monthIndex = findMonthIndex(for: newDate) {
            if monthIndex != currentMonthIndex {
                currentMonthIndex = monthIndex
            }
        }
    }

    func generateCalendarDaysIfNeeded(for index: Int) {
        guard index >= 0, index < months.count, monthCalendarCache[index] == nil else { return }

        let days = generateCalendarDays(for: months[index])
        monthCalendarCache[index] = days
    }

    func cacheCalendarDays(for index: Int) {
        guard index >= 0, index < months.count, monthCalendarCache[index] == nil else { return }

        let days = generateCalendarDays(for: months[index])
        monthCalendarCache[index] = days
    }

    func getCalendarDays(for index: Int) -> [[Date?]] {
        if let cached = monthCalendarCache[index] {
            return cached
        }

        guard index >= 0, index < months.count else { return [] }
        return generateCalendarDays(for: months[index])
    }

    func loadProgressForMonth(at index: Int) {
        let days = getCalendarDays(for: index).flatMap { $0 }.compactMap { $0 }

        for date in days {
            let startOfDay = calendar.startOfDay(for: date)
            progressCache[startOfDay] = habit.completionPercentageForDate(date)
        }
    }

    func handleMonthChange(newIndex: Int) {
        generateCalendarDaysIfNeeded(for: newIndex)
        loadProgressForMonth(at: newIndex)

        // Preload adjacent months for smoother scrolling
        if newIndex > 0 {
            generateCalendarDaysIfNeeded(for: newIndex - 1)
        }
        if newIndex < months.count - 1 {
            generateCalendarDaysIfNeeded(for: newIndex + 1)
        }
    }

    func clearDetailSheet() {
        detailSheetDate = nil
        // Reload progress for current month after sheet dismiss
        loadProgressForMonth(at: currentMonthIndex)
    }

    // MARK: - Navigation

    var currentMonthDate: Date {
        guard months.indices.contains(currentMonthIndex) else { return Date() }
        return months[currentMonthIndex]
    }

    var canNavigateToPreviousMonth: Bool {
        currentMonthIndex > 0
    }

    var canNavigateToNextMonth: Bool {
        guard !months.isEmpty else { return false }

        let current = calendar.dateComponents([.year, .month], from: Date())
        let displayed = calendar.dateComponents([.year, .month], from: currentMonthDate)

        let currentYear = current.year ?? 0
        let currentMonth = current.month ?? 0
        let displayedYear = displayed.year ?? 0
        let displayedMonth = displayed.month ?? 0

        if displayedYear < currentYear {
            return true
        }

        if displayedYear == currentYear {
            return displayedMonth < currentMonth
        }

        return false
    }

    func showPreviousMonth() {
        guard canNavigateToPreviousMonth else { return }
        currentMonthIndex -= 1
    }

    func showNextMonth() {
        guard canNavigateToNextMonth else { return }
        currentMonthIndex += 1
    }

    // MARK: - Private Methods

    private func generateMonths() {
        let today = Date()
        let effectiveStartDate = HistoryLimits.limitStartDate(habit.startDate)

        let startComponents = calendar.dateComponents([.year, .month], from: effectiveStartDate)
        let todayComponents = calendar.dateComponents([.year, .month], from: today)

        guard let startMonth = calendar.date(from: startComponents),
              let currentMonth = calendar.date(from: todayComponents) else {
            months = [today]
            return
        }

        var generatedMonths: [Date] = []
        var currentDate = startMonth

        while currentDate <= currentMonth {
            generatedMonths.append(currentDate)

            guard let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: currentDate) else {
                break
            }
            currentDate = nextMonth
        }

        months = generatedMonths.isEmpty ? [currentMonth] : generatedMonths
    }

    private func findMonthIndex(for date: Date) -> Int? {
        let targetComponents = calendar.dateComponents([.year, .month], from: date)

        for (index, month) in months.enumerated() {
            let monthComponents = calendar.dateComponents([.year, .month], from: month)
            if monthComponents.year == targetComponents.year && monthComponents.month == targetComponents.month {
                return index
            }
        }

        return nil
    }

    private func prepareInitialData() {
        generateCalendarDaysIfNeeded(for: currentMonthIndex)
        loadProgressForMonth(at: currentMonthIndex)
    }

    private func generateCalendarDays(for month: Date) -> [[Date?]] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        var firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - calendar.firstWeekday
        if firstWeekday < 0 { firstWeekday += 7 }

        guard let startDate = calendar.date(byAdding: .day, value: -firstWeekday, to: firstDayOfMonth) else {
            return []
        }

        guard let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: firstDayOfMonth),
              let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return []
        }

        var daysGrid: [[Date?]] = []
        var currentDate = startDate
        var hasReachedEnd = false

        for _ in 0..<6 {
            var week: [Date?] = []

            for _ in 0..<7 {
                let isInCurrentMonth = calendar.isDate(currentDate, equalTo: month, toGranularity: .month)
                week.append(isInCurrentMonth ? currentDate : nil)

                if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDate
                }
            }

            daysGrid.append(week)

            if !hasReachedEnd && currentDate > lastDayOfMonth {
                hasReachedEnd = true
            }

            if hasReachedEnd && daysGrid.count >= 4 {
                break
            }
        }

        while daysGrid.count < 6 {
            daysGrid.append(Array(repeating: nil, count: 7))
        }

        return daysGrid
    }
}
