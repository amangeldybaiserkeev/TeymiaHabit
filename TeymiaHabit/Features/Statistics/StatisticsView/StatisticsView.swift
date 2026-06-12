import SwiftUI
import SwiftData

struct StatisticsView: View {

    @Query(
        filter: #Predicate<Habit> { !$0.isArchived },
        sort: \Habit.displayOrder
    ) private var habits: [Habit]

    var body: some View {
        Group {
            if habits.isEmpty {
                ContentUnavailableView("No Habits", systemImage: "checkmark.circle.dotted")
            } else {
                habitsList
            }
        }
    }

    private var habitsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.reg) {
                ForEach(habits) { habit in
                    HabitStatCard(habit: habit)
                        .padding(.horizontal, Spacing.reg)
                }
            }
        }
        .navigationTitle("Statistics")
    }
}

// MARK: - StatisticsEmptyView

private struct StatisticsEmptyView: View {
    let action: () -> Void
    private let iconSize = IconSize.lg

    var body: some View {
        EmptyStateView(
            title: "Discover Your Habit Insights",
            message: "Track your progress, view detailed statistics, " +
            "and stay motivated as your habits grow stronger every day",
            buttonTitle: "Create a New Habit",
            action: action,
            footerText: "Build better habits every day"
        ) {
            icon
        }
    }

    private var icon: some View {
        Image(systemName: "chart.bar.xaxis.ascending")
            .font(.system(size: iconSize))
            .symbolRenderingMode(.palette)
            .foregroundStyle(Color.secondary.gradient, Color.primary.gradient)
            .frame(size: iconSize * 1.8)
            .background(Color.secondary, in: .circle)

    }
}
