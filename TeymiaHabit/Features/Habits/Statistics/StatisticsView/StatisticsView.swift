import SwiftUI
import SwiftData

struct StatisticsView: View {

    @Query(
        filter: #Predicate<Habit> { !$0.isArchived },
        sort: \Habit.displayOrder
    ) private var habits: [Habit]

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.reg) {
                if habits.isEmpty {
                    emptyView
                } else {
                    LazyVStack(spacing: DS.Spacing.reg) {
                        ForEach(habits) { habit in
                            HabitStatCard(habit: habit)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.reg)
                }
            }
            .padding(.vertical, DS.Spacing.sm)
        }
        .navigationTitle("Statistics")
    }

    // MARK: - Subviews

    private var emptyView: some View {
        ContentUnavailableView(
            "No Habits",
            systemImage: "chart.bar.fill",
            description: Text("Add your first habit to track progress")
        )
        .padding(.top, DS.Spacing.xxl)
    }
}
