import SwiftUI
import SwiftData

struct StatisticsView: View {

    @State private var showingNewHabit = false

    @Query(
        filter: #Predicate<Habit> { !$0.isArchived },
        sort: \Habit.displayOrder
    ) private var habits: [Habit]

    var body: some View {
        Group {
            if habits.isEmpty {
                StatisticsEmptyView {
                    showingNewHabit = true
                }
            } else {
                habitsList
            }
        }
        .appBackground()
        .sheet(isPresented: $showingNewHabit) {
            NewHabitView()
        }
    }

    private var habitsList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.reg) {
                ForEach(habits) { habit in
                    HabitStatCard(habit: habit)
                        .padding(.horizontal, DS.Spacing.reg)
                }
            }
            .applyAdaptiveWidth()
        }
        .navigationTitle("Statistics")
    }
}

// MARK: - StatisticsEmptyView

private struct StatisticsEmptyView: View {
    let action: () -> Void
    private let iconSize = DS.IconSize.lg

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
            .foregroundStyle(DS.Colors.secondary.gradient, DS.Colors.primary.gradient)
            .frame(size: iconSize * 1.8)
            .background(DS.Colors.tertiary, in: .circle)

    }
}
