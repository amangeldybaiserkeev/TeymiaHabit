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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                HabitIconView(icon: habit.iconName, color: habit.iconColor)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(habit.title)
                        .font( .headline)

                    Text("Goal: \(habit.formattedGoal)")
                        .font( .subheadline)
                }
                .foregroundStyle(Color.primary)
                .lineLimit(1)
            }

            StreaksView(
                current: vm.currentStreak,
                best: vm.bestStreak,
                total: vm.totalValue
            )
        }
        .padding( Spacing.reg)
        .glassEffect(
            .regular.interactive(), in: .rect(cornerRadius: Radius.lg)
        )
        .contentShape(.rect(cornerRadius: Radius.lg))
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
