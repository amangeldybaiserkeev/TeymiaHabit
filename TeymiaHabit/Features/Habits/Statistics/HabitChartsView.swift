import SwiftUI
import Charts

struct HabitCharts: View {
    let habit: Habit
    @State private var vm: HabitChartsViewModel

    init(habit: Habit, range: ChartTimeRange) {
        self.habit = habit
        self._vm = State(initialValue: HabitChartsViewModel(habit: habit, range: range))
    }

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            StatsPeriodHeader(
                title: vm.periodTitle,
                onPrevious: vm.previous,
                onNext: vm.next,
                canGoPrevious: vm.currentIndex > 0,
                canGoNext: vm.canNavigateToNext
            )

            ChartStatsRow(
                averageLabel: chartAverageFormatted(chartData: vm.chartData, habitType: habit.type),
                totalLabel: chartTotalFormatted(chartData: vm.chartData, habitType: habit.type),
                selectedDateLabel: vm.selectedDate.map { vm.shortDateFormatter.string(from: $0) },
                selectedValueLabel: vm.selectedDateValueLabel
            )

            ChartContainer(currentIndex: $vm.currentIndex, count: vm.periods.count) {
                chartView
            }
            .onChange(of: vm.currentIndex) { _, _ in
                vm.generateChartData()
            }
        }
        .sensoryFeedback(trigger: vm.selectedDate) { old, new in
            shouldPlayChartHaptic(old: old, new: new, calendar: calendar) ? .selection : nil
        }
        .onAppear { vm.generateChartData() }
        .onChange(of: habit.goal) { _, _ in vm.generateChartData() }
    }

    private var chartView: some View {
        Chart(vm.chartData) { dataPoint in
            BarMark(
                x: .value("Period", dataPoint.date, unit: vm.range.xUnit),
                y: .value("Progress", dataPoint.value)
            )
            .foregroundStyle(habitBarColor(for: dataPoint, habit: habit))
            .cornerRadius(vm.range == .month ? 4 : 8)
            .opacity(habitBarOpacity(for: dataPoint.date, selected: vm.selectedDate, calendar: calendar))
        }
        .chartXAxis {
            let axisValues = vm.xAxisValues
            let currentRange = vm.range

            AxisMarks(values: axisValues) { (value: AxisValue) in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6, dash: [2]))
                    .foregroundStyle(DS.Colors.primary.opacity(0.2).gradient)

                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(currentRange.xAxisLabel(for: date, calendar: calendar))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(DS.Colors.primary.opacity(0.5).gradient)
                    }
                }
            }
        }
        .habitChartYAxis(values: habitChartYAxisValues(for: vm.chartData, habitType: habit.type))
        .chartXSelection(value: $vm.selectedDate)
        .onTapGesture {
            if vm.selectedDate != nil {
                withAnimation(DS.Animations.easeInOut) { vm.selectedDate = nil }
            }
        }
        .frame(height: 180)
    }
}
