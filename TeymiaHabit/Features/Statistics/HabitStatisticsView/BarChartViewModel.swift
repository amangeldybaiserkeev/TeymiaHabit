import SwiftUI
import Charts

@Observable
final class BarChartViewModel {
    let habit: Habit
    var range: ChartTimeRange
    var periods: [Date] = []
    var currentIndex: Int = 0
    var chartData: [ChartDataPoint] = []
    var selectedDate: Date? {
        didSet { roundSelectedDate() }
    }

    let calendar = Calendar.current

    // MARK: - Init
    init(habit: Habit, range: ChartTimeRange) {
        self.habit = habit
        self.range = range
        setupPeriods()
        goToCurrentPeriod()
    }
    // MARK: - View Data (Computed)

    var canNavigateToNext: Bool { currentIndex < periods.count - 1 }
    var averageLabel: String { chartAverageFormatted(chartData: chartData, habitType: habit.type) }
    var totalLabel: String { chartTotalFormatted(chartData: chartData, habitType: habit.type) }

    var periodTitle: String {
        guard periods.indices.contains(currentIndex) else { return "" }
        let date = periods[currentIndex]

        switch range {
        case .week:  return formatWeeklyRange(for: date)
        case .month: return date.nominativeMonth()
        case .year:  return "\(calendar.component(.year, from: date))"
        }
    }

    var chartGradient: LinearGradient {
        LinearGradient(
            colors: [habit.iconColor.ringPair.light, habit.iconColor.ringPair.dark],
            startPoint: .top, endPoint: .bottom
        )
    }

    var xAxisValues: [Date] {
        guard range == .month else {
            return chartData.map { point in point.date }
        }

        return stride(from: 0, to: chartData.count, by: 5).map { index in
            chartData[index].date
        }
    }

    var selectedDateValueLabel: String? {
        guard let selectedDate, let point = findPoint(for: selectedDate) else { return nil }
        return point.formattedValueWithoutSeconds
    }

    var selectedPoint: ChartDataPoint? {
        guard let selectedDate else { return nil }
        return chartData.first { isSamePeriod($0.date, selectedDate) }
    }

    // MARK: - Public Methods

    func generateChartData() {
        guard !periods.isEmpty, currentIndex < periods.count else {
            chartData = []; return
        }

        let startOfPeriod = periods[currentIndex]
        let numberOfSteps = range.stepsCount(for: startOfPeriod, calendar: calendar)

        chartData = (0..<numberOfSteps).compactMap { offset in
            guard let date = calendar.date(
                byAdding: range.stepComponent, value: offset, to: startOfPeriod
            ) else { return nil }

            let progress = (range == .year)
            ? calculateMonthlyProgress(for: date)
            : (date <= Date() && date >= calendar.startOfDay(for: habit.startDate) ? habit.progressForDate(date) : 0)

            return ChartDataPoint(date: date, value: progress, goal: habit.goal, habitType: habit.type)
        }
    }

    func opacity(for date: Date) -> Double {
        guard let selectedDate else { return 1.0 }
        let granularity: Calendar.Component = (range == .year) ? .month : .day
        return calendar.isDate(date, equalTo: selectedDate, toGranularity: granularity) ? 1.0 : 0.3
    }

    func isPointSelected(_ point: ChartDataPoint, selectedDate: Date) -> Bool {
        isSamePeriod(point.date, selectedDate)
    }

    func shouldTriggerHaptic(old: Date?, new: Date?) -> Bool {
        guard let new else { return false }
        guard let old else { return true }
        return !isSamePeriod(old, new)
    }

    var maxChartValue: Double {
        let maxValue = chartData.map { Double($0.value) }.max() ?? 0
        return max(maxValue, Double(habit.goal))
    }

    // MARK: - Navigation
    func next() { navigate(by: 1) }
    func previous() { navigate(by: -1) }

    private func navigate(by offset: Int) {
        let newIndex = currentIndex + offset
        if periods.indices.contains(newIndex) {
            currentIndex = newIndex
            selectedDate = nil
            generateChartData()
        }
    }
}

// MARK: - Logic
private extension BarChartViewModel {
    func isSamePeriod(_ d1: Date, _ d2: Date) -> Bool {
        let granularity: Calendar.Component = (range == .year) ? .month : .day
        return calendar.isDate(d1, equalTo: d2, toGranularity: granularity)
    }

    func findPoint(for date: Date) -> ChartDataPoint? {
        chartData.first { isSamePeriod($0.date, date) }
    }

    func roundSelectedDate() {
        guard let date = selectedDate else { return }
        let component: Calendar.Component = (range == .year) ? .month : .day
        if let rounded = calendar.dateInterval(of: component, for: date)?.start, rounded != date {
            selectedDate = rounded
        }
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
        let targetIndex = periods.firstIndex { date in
            calendar.isDate(date, equalTo: todayStart, toGranularity: range.component)
        }

        if let index = targetIndex {
            currentIndex = index
        } else {
            currentIndex = max(0, periods.count - 1)
        }

        generateChartData()
    }

    func habitChartYAxisValues(for data: [ChartDataPoint], habitType: HabitType) -> [Int] {
        guard !data.isEmpty else { return [0] }
        let maxValue = data.map { $0.value }.max() ?? 0
        guard maxValue > 0 else { return [0] }

        let displayMax = habitType == .time ? maxValue / 3600 : maxValue
        let step = max(1, displayMax / 3)
        let values = [0, step, step * 2, step * 3].filter { $0 <= displayMax + step / 2 }

        return habitType == .time ? values.map { $0 * 3600 } : values
    }

    func calculateMonthlyProgress(for monthDate: Date) -> Int {
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
}

// MARK: - Formatting
extension BarChartViewModel {

    func chartAverageFormatted(chartData: [ChartDataPoint], habitType: HabitType) -> String {
        let active = chartData.filter { $0.value > 0 }
        guard !active.isEmpty else { return "0" }
        let average = active.reduce(0) { $0 + $1.value } / active.count
        return habitType == .time ? average.formattedAsChartDuration() : "\(average)"
    }

    func chartTotalFormatted(chartData: [ChartDataPoint], habitType: HabitType) -> String {
        let total = chartData.reduce(0) { $0 + $1.value }
        return habitType == .time ? total.formattedAsChartDuration() : "\(total)"
    }

    func formatYAxis(_ value: Double) -> String {
        if habit.type == .time {
            let hours = Int(round(value / 3600.0))
            return "\(hours)h"
        } else {
            return "\(Int(value))"
        }
    }

    func formatSelectionTitle(for date: Date) -> String {
        range == .year
        ? date.nominativeMonth()
        : date.formatted(.dateTime.day().month(.wide)).capitalized
    }

    func formatWeeklyRange(for date: Date) -> String {
        let calendar = Calendar.userPreferred

        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return ""
        }

        let startOfWeek = interval.start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? interval.end

        let sDay = calendar.component(.day, from: startOfWeek)
        let eDay = calendar.component(.day, from: endOfWeek)
        let sMonth = calendar.component(.month, from: startOfWeek)
        let eMonth = calendar.component(.month, from: endOfWeek)

        let df = DateFormatter()
        df.locale = Locale.current

        if sMonth != eMonth {
            df.dateFormat = "d MMM"
            let startStr = df.string(from: startOfWeek)
            let endStr = df.string(from: endOfWeek)
            return "\(startStr) – \(endStr)"
        }

        df.dateFormat = "MMM"
        return "\(sDay) – \(eDay) \(df.string(from: startOfWeek))"
    }
}

// MARK: - Y-Axis
extension BarChartViewModel {
//    var yAxisValues: [Double] {
//        let rawMax = maxChartValue
//
//        if habit.type == .time {
//            let maxHours = ceil(rawMax / 3600.0)
//            let finalMaxHours = maxHours.truncatingRemainder(dividingBy: 2) == 0 ? maxHours : maxHours + 1
//
//            return [0, (finalMaxHours / 2) * 3600, finalMaxHours * 3600]
//        } else {
//            let maxVal = ceil(rawMax)
//            let finalMax = maxVal.truncatingRemainder(dividingBy: 2) == 0 ? maxVal : maxVal + 1
//            return [0, finalMax / 2, finalMax]
//        }
//    }

//    var adjustedMaxY: Double {
//        yAxisValues.last ?? maxChartValue
//    }
    func formatMinutesToReadable(_ minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60

        if hours > 0 {
            if mins > 0 {
                return "\(hours)h \(mins)m"
            }
            return "\(hours)h"
        }
        return "\(mins)m"
    }
}
