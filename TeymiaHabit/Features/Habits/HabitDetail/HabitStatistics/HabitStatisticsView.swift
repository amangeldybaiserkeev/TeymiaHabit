import SwiftUI

struct HabitStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var statsViewModel: HabitStatsViewModel
    @Binding var selectedDate: Date
    @Binding var barChartTimeRange: ChartTimeRange
    
    let habit: Habit
    @State private var updateCounter = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    StreaksView(viewModel: statsViewModel)
                }
                .listRowInsets(EdgeInsets())
                
                Section {
                    MonthlyCalendarView(
                        habit: habit,
                        selectedDate: $selectedDate,
                        updateCounter: updateCounter,
                        onActionRequested: handleCalendarAction,
                        onCountInput: { val, date in handleCustomCountInput(count: val, targetDate: date) },
                        onTimeInput: { h, m, date in handleCustomTimeInput(hours: h, minutes: m, targetDate: date) }
                    )
                }
                .listRowInsets(EdgeInsets())
                
                Section {
                    VStack(spacing: 30) {
                        TimeRangePicker(selection: $barChartTimeRange)
                            .padding(.horizontal, 16)
                        
                        barChartContent.frame(height: 240)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.insetGrouped)
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()
            }
        }
    }
    
    @ViewBuilder
    private var barChartContent: some View {
        switch barChartTimeRange {
        case .week: WeeklyHabitChart(habit: habit, updateCounter: updateCounter)
        case .month: MonthlyHabitChart(habit: habit, updateCounter: updateCounter)
        case .year: YearlyHabitChart(habit: habit, updateCounter: updateCounter)
        }
    }
    
    private func handleCalendarAction(_ action: CalendarAction, date: Date) {
            switch action {
            case .complete: habit.complete(for: date, modelContext: modelContext)
            case .resetProgress: habit.resetProgress(for: date, modelContext: modelContext)
            }
            saveAndRefresh()
        }

        private func handleCustomCountInput(count: Int, targetDate: Date) {
            habit.addToProgress(count, for: targetDate, modelContext: modelContext)
            saveAndRefresh()
        }

        private func handleCustomTimeInput(hours: Int, minutes: Int, targetDate: Date) {
            let totalValue = (hours * 3600) + (minutes * 60)
            habit.addToProgress(totalValue, for: targetDate, modelContext: modelContext)
            saveAndRefresh()
        }

        private func saveAndRefresh() {
            try? modelContext.save()
            statsViewModel.refresh()
            updateCounter += 1
            HapticManager.shared.play(.success)
        }
}
