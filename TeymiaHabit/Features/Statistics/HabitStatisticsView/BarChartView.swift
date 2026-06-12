import SwiftUI
import Charts

struct BarChartView: View {
    let habit: Habit
    @State private var vm: BarChartViewModel

    init(habit: Habit, range: ChartTimeRange) {
        self.habit = habit
        self._vm = State(initialValue: BarChartViewModel(habit: habit, range: range))
    }

    private enum Constants {
        static let xAxisColor = Color.secondary.opacity(0.7)
        static let yAxisColor = Color.secondary.opacity(0.3)
        static let chartHeight: CGFloat = 180
        static let tabViewHeight: CGFloat = 280
        static let gridLineWidth: CGFloat = 0.5
        static let gridDash: [CGFloat] = [2, 4]

        static func barCornerRadius(for range: ChartTimeRange) -> CGFloat {
            range == .month ? 2 : 4
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsPeriodHeader(
                title: vm.periodTitle,
                onPrevious: vm.previous,
                onNext: vm.next,
                canGoPrevious: vm.currentIndex > 0,
                canGoNext: vm.canNavigateToNext
            )

            ChartContainer(count: vm.periods.count, currentIndex: $vm.currentIndex) {
                chartView
            }
        }
        .onAppear {
            if vm.chartData.isEmpty {
                vm.generateChartData()
            }
        }
        .onChange(of: habit.goal) { _, newGoal in
            if newGoal != habit.goal {
                vm.generateChartData()
            }
        }
        .onChange(of: vm.currentIndex) { _, _ in
            vm.generateChartData()
        }
        .sensoryFeedback(.selection, trigger: vm.selectedDate) { old, new in
            vm.shouldTriggerHaptic(old: old, new: new)
        }
    }

    @ViewBuilder
    private var chartView: some View {
        VStack(spacing: 0) {
            ChartStatsRow(averageLabel: vm.averageLabel, totalLabel: vm.totalLabel)
                .padding(.bottom, Spacing.md)

            Chart(vm.chartData) { dataPoint in
                selectionOverlay

                BarMark(
                    x: .value("", dataPoint.date, unit: vm.range.xUnit),
                    y: .value("", dataPoint.displayValue)
                )
                .foregroundStyle(vm.chartGradient)
                .cornerRadius(Constants.barCornerRadius(for: vm.range))
                .opacity(vm.opacity(for: dataPoint.date))
            }
            .frame(height: Constants.chartHeight)
            .chartXSelection(value: $vm.selectedDate.animation( Animations.easeInOut))
            .chartXAxis { xAxisMarks }
            .chartYAxis { yAxisMarks }
            .chartYScale(domain: .automatic(includesZero: habit.type == .count))
        }
    }

    @AxisContentBuilder
    private var xAxisMarks: some AxisContent {
        AxisMarks(values: vm.xAxisValues) { (value: AxisValue) in
            AxisGridLine(stroke: StrokeStyle(lineWidth: Constants.gridLineWidth, dash: Constants.gridDash))
                .foregroundStyle(Constants.xAxisColor)
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(vm.range.xAxisLabel(for: date, calendar: vm.calendar))
                        .font( .caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }

    @AxisContentBuilder
    private var yAxisMarks: some AxisContent {
        AxisMarks { value in
            AxisGridLine(stroke: StrokeStyle(lineWidth: Constants.gridLineWidth))
                .foregroundStyle(Constants.yAxisColor)
            AxisValueLabel {
                if let minutes = value.as(Double.self) {
                    Text(vm.formatMinutesToReadable(minutes))
                        .font( .caption)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }

    @ChartContentBuilder
    private var selectionOverlay: some ChartContent {
        if let selectedPoint = vm.selectedPoint {
            RuleMark(x: .value("", selectedPoint.date, unit: vm.range.xUnit))
                .foregroundStyle(vm.chartGradient.opacity(0.8))
                .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                    ChartSelectionAnnotation(
                        title: vm.formatSelectionTitle(for: selectedPoint.date),
                        valueLabel: vm.selectedDateValueLabel ?? "",
                        color: vm.chartGradient
                    )
                }
        }
    }
}

// MARK: - Private Subviews

private enum ChartContainerConstants {
    static let tabViewHeight: CGFloat = 280
}

private struct ChartContainer<Content: View>: View {
    let count: Int
    @Binding var currentIndex: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<count, id: \.self) { index in
                content()
                    .tag(index)
                    .padding(.horizontal, Spacing.reg)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: ChartContainerConstants.tabViewHeight)
    }
}

private struct ChartSelectionAnnotation: View {
    let title: String
    let valueLabel: String
    let color: LinearGradient

    private enum LocalConstants {
        static let width: CGFloat = 120
    }

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text(title)
                .font( .headline)

            Text(valueLabel)
                .font( .title3)
                .bold()
        }
        .foregroundStyle(.onPrimary)
        .padding( Spacing.sm)
        .frame(width: LocalConstants.width)
        .background {
            RoundedRectangle(cornerRadius: Radius.reg)
                .fill(color.opacity(0.8))
        }
    }
}
