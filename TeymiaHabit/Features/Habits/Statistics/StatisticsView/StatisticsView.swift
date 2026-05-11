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
                    emptyState
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
        .navigationTitle("tabview_statistics")
    }

    // MARK: - Subviews

    private var emptyState: some View {
        ContentUnavailableView(
            "no_habits",
            systemImage: "chart.bar",
            description: Text("statistics_empty_description")
        )
        .padding(.top, DS.Spacing.xxl)
    }
}
