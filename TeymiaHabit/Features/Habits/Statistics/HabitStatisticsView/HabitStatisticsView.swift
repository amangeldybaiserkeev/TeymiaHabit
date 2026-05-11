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
                    HStack {
                        Label {
                            Text("Total all time")
                                .foregroundStyle(DS.Colors.primary)
                        } icon: {
                            RowIcon(iconName: "hand.thumbsup")
                        }
                        Spacer()
                        Text(vm.formattedTotal)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(#colorLiteral(red: 0.9961017966, green: 0.4863132238, blue: 0.1490832567, alpha: 1)), Color(#colorLiteral(red: 0.9961031079, green: 0.2039290071, blue: 0.01577392034, alpha: 1))],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }

                Section {
                    MonthlyCalendarView(
                        habit: habit,
                        selectedDate: $vm.selectedDate
                    )
                }
                .listRowInsets(EdgeInsets())

                Section {
                    VStack(spacing: DS.Spacing.md) {
                        TimeRangePicker(selection: $vm.barChartTimeRange)

                        BarChartView(habit: habit, range: vm.barChartTimeRange)
                            .id("\(habit.uuid.uuidString)-\(vm.barChartTimeRange.rawValue)")
                    }
                    .padding(.top, DS.Spacing.reg)
                } footer: {
                    HStack(spacing: DS.Spacing.xxs) {
                        Image(systemName: "hand.tap")
                        Text("Press and hold bars for details")
                    }
                    .foregroundStyle(DS.Colors.secondary)
                    .padding(.leading, DS.Spacing.reg)
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

