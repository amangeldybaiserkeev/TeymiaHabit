import SwiftUI
import SwiftData

struct ArchiveRow: View {
    private let option = SettingsOption.archive

    var body: some View {
        NavigationRow(
            title: option.title,
            icon: SettingsRowIcon(option: option),
            destination: ArchiveView()
        )
    }
}

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var habitToDelete: Habit?
    @Query(
        filter: #Predicate<Habit> { $0.isArchived },
        sort: [SortDescriptor(\Habit.createdAt, order: .reverse)]
    )
    private var archivedHabits: [Habit]

    var body: some View {
        Group {
            if archivedHabits.isEmpty {
                emptyView
            } else {
                habitList
            }
        }
    }

    private var habitList: some View {
        List {
            ForEach(archivedHabits) { habit in
                archivedHabitRow(habit)
            }
        }
        .navigationTitle("Archive")
        .deleteHabitAlert(habit: $habitToDelete) { habit in
            deleteHabit(habit)
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            title: "No Archived Habits",
            message: "Habits you archive will appear here."
        ) {
            Image(systemName: "archivebox.fill")
                .font(.system(size: IconSize.xxl))
                .foregroundStyle(Color.secondary.opacity(0.5))
        }
    }

    @ViewBuilder
    private func archivedHabitRow(_ habit: Habit) -> some View {
        HStack(spacing: Spacing.sm) {
            HabitIconView(icon: habit.iconName, color: habit.iconColor)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(habit.title)
                    .lineLimit(1)
                    .foregroundStyle(Color.primary)
                Text("goal \(habit.formattedGoal)")
                    .font( .caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                unarchiveHabit(habit)
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .buttonStyle(.glass)

            Button(role: .destructive) {
                habitToDelete = habit
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }

    private func unarchiveHabit(_ habit: Habit) {
        habit.isArchived = false
        try? modelContext.save()
    }

    private func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
    }
}
