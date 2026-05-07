import Foundation

@Observable
final class HabitChartsViewModel {
    let habit: Habit
    var range: ChartTimeRange
    var periods: [Date] = []
    var currentIndex: Int = 0
    var chartData: [ChartDataPoint] = []
    var selectedDate: Date?

    private let calendar = Calendar.current

    let shortDateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()

    init(habit: Habit, range: ChartTimeRange) {
        self.habit = habit
        self.range = range
        setupPeriods()
        goToCurrentPeriod()
    }

    var canNavigateToNext: Bool {
        currentIndex < periods.count - 1
    }

    var xAxisValues: [Date] {
        switch range {
        case .month:
            return stride(from: 0, to: chartData.count, by: 5).compactMap {
                chartData.indices.contains($0) ? chartData[$0].date : nil
            }
        default:
            return chartData.map { $0.date }
        }
    }

    var selectedDateValueLabel: String? {
        guard let selectedDate else { return nil }
        let point = chartData.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        return point?.formattedValueWithoutSeconds
    }

    func setupPeriods() {
        let today = Date()
        let habitStart = habit.startDate
        let effectiveStart = calendar.dateInterval(of: range.component, for: habitStart)?.start ?? habitStart
        let todayStart = calendar.dateInterval(of: range.component, for: today)?.start ?? today

        var list: [Date] = []
        var current = effectiveStart

        while current <= todayStart {
            list.append(current)
            guard let next = calendar.date(byAdding: range.component, value: 1, to: current) else { break }
            current = next
        }
        self.periods = list
    }

    func goToCurrentPeriod() {
        let todayStart = calendar.dateInterval(of: range.component, for: Date())?.start ?? Date()
        if let idx = periods.firstIndex(where: { calendar.isDate($0, equalTo: todayStart, toGranularity: range.component) }) {
            currentIndex = idx
        } else {
            currentIndex = max(0, periods.count - 1)
        }
        generateChartData()
    }

    func generateChartData() {
        guard !periods.isEmpty, currentIndex < periods.count else {
            chartData = []
            return
        }

        let startOfPeriod = periods[currentIndex]
        let numberOfSteps = range.stepsCount(for: startOfPeriod, calendar: calendar)

        chartData = (0..<numberOfSteps).compactMap { offset in
            guard let date = calendar.date(byAdding: range.stepComponent, value: offset, to: startOfPeriod) else { return nil }

            let progress: Int

            if range == .year {
                progress = calculateMonthlyProgress(for: date)
            } else {
                let isValidDate = date <= Date() && date >= calendar.startOfDay(for: habit.startDate)
                progress = isValidDate ? habit.progressForDate(date) : 0
            }

            return ChartDataPoint(
                date: date,
                value: progress,
                goal: habit.goal,
                habitType: habit.type
            )
        }
    }

    private func calculateMonthlyProgress(for monthDate: Date) -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else { return 0 }

        return (1...range.count).reduce(0) { total, day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay),
                  date >= calendar.startOfDay(for: habit.startDate),
                  date <= Date()
            else { return total }
            return total + habit.progressForDate(date)
        }
    }

    // MARK: - Navigation
    func next() {
        if currentIndex < periods.count - 1 {
            currentIndex += 1
            selectedDate = nil
            generateChartData()
        }
    }

    func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
            selectedDate = nil
            generateChartData()
        }
    }

    var periodTitle: String {
        guard !periods.isEmpty else { return "" }
        let date = periods[currentIndex]
        return DateFormatter.capitalizedNominativeMonthYear(from: date)
    }
}
