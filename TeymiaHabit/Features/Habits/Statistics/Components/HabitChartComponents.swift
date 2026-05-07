import SwiftUI
import Charts

// MARK: - Y-Axis Values

/// Computes up to 4 evenly spaced Y-axis tick values based on the chart data max
func habitChartYAxisValues(for data: [ChartDataPoint], habitType: HabitType) -> [Int] {
    guard !data.isEmpty else { return [0] }

    let maxValue = data.map { $0.value }.max() ?? 0
    guard maxValue > 0 else { return [0] }

    let displayMax = habitType == .time ? maxValue / 3600 : maxValue
    let step = max(1, displayMax / 3)
    let values = [0, step, step * 2, step * 3].filter { $0 <= displayMax + step / 2 }

    return habitType == .time ? values.map { $0 * 3600 } : values
}

// MARK: - Shared Bar Color Logic

/// Returns the appropriate gradient color for a bar based on habit state
func habitBarColor(for dataPoint: ChartDataPoint, habit: Habit) -> AnyGradient {
    if !habit.isActiveOnDate(dataPoint.date) || dataPoint.date > Date() {
        return Color.secondary.gradient
    }

    if dataPoint.value == 0 {
        return Color.secondary.opacity(0.3).gradient
    }

    if dataPoint.isCompleted || dataPoint.isOverAchieved {
        return habit.iconColor.baseColor.gradient
    } else {
        return habit.iconColor.baseColor.opacity(0.8).gradient
    }
}

/// Returns opacity based on selection state
func habitBarOpacity(for date: Date, selected: Date?, calendar: Calendar) -> Double {
    guard let selected else { return 1.0 }
    return calendar.isDate(date, inSameDayAs: selected) ? 1.0 : 0.3
}

// MARK: - Shared Haptic Logic

func shouldPlayChartHaptic(old: Date?, new: Date?, calendar: Calendar) -> Bool {
    if let old, let new, !calendar.isDate(old, inSameDayAs: new) {
        return true
    } else if old == nil && new != nil {
        return true
    }
    return false
}

// MARK: - Chart Stats Formatting

/// Formats average value from chart data
func chartAverageFormatted(chartData: [ChartDataPoint], habitType: HabitType) -> String {
    let active = chartData.filter { $0.value > 0 }
    guard !active.isEmpty else { return "0" }
    let avg = active.reduce(0) { $0 + $1.value } / active.count
    return habitType == .time ? avg.formattedAsChartDuration() : "\(avg)"
}

/// Formats total value from chart data
func chartTotalFormatted(chartData: [ChartDataPoint], habitType: HabitType) -> String {
    let total = chartData.reduce(0) { $0 + $1.value }
    return habitType == .time ? total.formattedAsChartDuration() : "\(total)"
}

// MARK: - Chart Container

struct ChartContainer<Content: View>: View {
    @Binding var currentIndex: Int
    let count: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<count, id: \.self) { index in
                content()
                    .tag(index)
                    .padding(.horizontal, DS.Spacing.reg)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 200)
    }
}

// MARK: - Chart Y-Axis View Modifier

/// Applies the standard trailing Y-axis with dashed grid lines
struct HabitChartYAxisModifier: ViewModifier {
    let values: [Int]

    func body(content: Content) -> some View {
        content
            .chartYAxis {
                AxisMarks(position: .trailing, values: values) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6, dash: [3]))
                        .foregroundStyle(DS.Colors.primary.opacity(0.2).gradient)
                }
            }
    }
}

extension View {
    func habitChartYAxis(values: [Int]) -> some View {
        modifier(HabitChartYAxisModifier(values: values))
    }
}
