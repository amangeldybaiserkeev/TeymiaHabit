import SwiftUI
import SwiftData

struct HabitStatCard: View {
    let habit: Habit

    @State private var vm: HabitStatisticsViewModel
    @State private var showingStats = false

    init(habit: Habit) {
        self.habit = habit
        _vm = State(wrappedValue: HabitStatisticsViewModel(habit: habit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.sm) {
                HabitIconView(iconName: habit.iconName, color: habit.iconColor.baseColor)

                VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                    Text(habit.title)
                        .font(DS.AppFont.headline)

                    Text("Goal: \(habit.formattedGoal)")
                        .font(DS.AppFont.subheadline)
                }
                .foregroundStyle(DS.Colors.primary)
                .lineLimit(1)
            }

            StreaksView(
                current: vm.currentStreak,
                best: vm.bestStreak,
                total: vm.totalValue
            )
        }
        .padding(DS.Spacing.reg)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DS.Radius.lg))
        .contentShape(.rect(cornerRadius: DS.Radius.lg))
        .onTapGesture {
            showingStats = true
        }
        .sensoryFeedback(.selection, trigger: showingStats) { old, new in
            new == true && old == false
        }
        .sheet(isPresented: $showingStats) {
            HabitStatisticsView(habit: habit)
        }
        .onChange(of: habit.completions) { _, _ in
            vm.refresh()
        }
    }
}
