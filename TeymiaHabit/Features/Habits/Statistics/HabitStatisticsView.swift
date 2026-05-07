import SwiftUI

struct HabitStatisticsView: View {
    let habit: Habit

    @State private var vm: HabitStatisticsViewModel

    init(habit: Habit) {
        self.habit = habit
        self._vm = State(wrappedValue: HabitStatisticsViewModel(habit: habit))
    }

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            List {
                Section {
                    StreaksView(current: vm.currentStreak, best: vm.bestStreak, total: vm.totalValue)
                }

                Section {
                    MonthlyCalendarView(
                        habit: habit,
                        selectedDate: $vm.selectedDate
                    )
                }
                .listRowInsets(EdgeInsets())

                Section {
                    VStack(spacing: DS.Spacing.reg) {
                        TimeRangePicker(selection: $vm.barChartTimeRange)

                        HabitCharts(habit: habit, range: vm.barChartTimeRange)
                            .id("\(habit.uuid.uuidString)-\(vm.barChartTimeRange.rawValue)")
                    }
                    .padding(.vertical, DS.Spacing.reg)
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .toolbar {
                CloseToolbarButton()
            }
            .onChange(of: habit.completions) { _, _ in
                vm.refresh()
            }
        }
    }
}

