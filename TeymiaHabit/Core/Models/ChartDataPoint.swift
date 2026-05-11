import SwiftUI

/// Represents a single data point for habit progress charts
/// Used in statistics views to display habit completion over time
struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Int
    let goal: Int
    let habitType: HabitType

    // MARK: - Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Progress Calculation

    var completionPercentage: Double {
        guard goal > 0 else { return 0 }
        return Double(value) / Double(goal)
    }

    var isCompleted: Bool {
        value >= goal
    }

    var isOverAchieved: Bool {
        value > goal
    }

    // MARK: - Formatting

    var formattedValue: String {
        habitType == .count ? "\(value)" : value.formattedAsTime()
    }

    var formattedGoal: String {
        habitType == .count ? "\(goal)" : goal.formattedAsLocalizedDuration()
    }

    /// Returns formatted time without seconds for cleaner chart display
    var formattedValueWithoutSeconds: String {
        habitType == .count ? "\(value)" : value.formattedAsChartDuration()
    }
}

enum ChartTimeRange: String, CaseIterable {
    case week, month, year

    var displayName: LocalizedStringKey {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var component: Calendar.Component {
        switch self {
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }

    var stepComponent: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .day
        case .year: return .month
        }
    }

    func stepsCount(for date: Date, calendar: Calendar) -> Int {
        switch self {
        case .week: return 7
        case .month:
            let range = calendar.range(of: .day, in: .month, for: date)
            return range?.count ?? 30
        case .year: return 12
        }
    }

    func xAxisLabel(for date: Date, calendar: Calendar) -> String {
        switch self {
        case .week:
            let index = calendar.component(.weekday, from: date) - 1
            return calendar.shortWeekdaySymbols[index]
        case .month:
            return "\(calendar.component(.day, from: date))"
        case .year:
            let f = DateFormatter(); f.dateFormat = "MMM"
            return String(f.string(from: date).prefix(1)).uppercased()
        }
    }

    var xUnit: Calendar.Component {
        switch self {
        case .week, .month: return .day
        case .year: return .month
        }
    }
}
