import SwiftUI
import SwiftData

struct ArchiveRow: View {
    var body: some View {
        NavigationLink {
            ArchiveView()
        } label: {
            Label {
                Text("Archive")
            } icon: {
                RowIcon(symbol: .archive)
            }
        }
    }
}

struct ArchiveView: View {
    @Environment(AppDependencyContainer.self) private var appContainer

    @Query(
        filter: #Predicate<Habit> { $0.isArchived },
        sort: [SortDescriptor(\Habit.createdAt, order: .reverse)]
    )
    private var archivedHabits: [Habit]

    @State private var habitToDelete: Habit?

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
            .rowBackground()
        }
        .navigationTitle("Archive")
        .appBackground(.grouped)
        .deleteHabitAlert(habit: $habitToDelete) { habit in
            appContainer.habitService.delete(habit)
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            title: "No Archived Habits",
            message: "Habits you archive will appear here."
        ) {
            Image(systemName: "archivebox.fill")
                .font(.system(size: DS.IconSize.xxl))
                .foregroundStyle(DS.Colors.secondary.opacity(0.5))
        }
        .appBackground()
    }

    @ViewBuilder
    private func archivedHabitRow(_ habit: Habit) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            HabitIconView(iconName: habit.iconName, color: habit.iconColor.baseColor)

            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(habit.title)
                    .lineLimit(1)
                    .foregroundStyle(DS.Colors.primary)
                Text("goal \(habit.formattedGoal)")
                    .font(DS.AppFont.caption)
                    .foregroundStyle(DS.Colors.secondary)
            }

            Spacer()

            Button {
                appContainer.habitService.unarchive(habit)
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
}
