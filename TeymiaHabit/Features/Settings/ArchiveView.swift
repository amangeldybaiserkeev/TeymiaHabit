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
                RowIcon(iconName: "archivebox")
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
        List {
            listContent
        }
        .navigationTitle("Archive")
        .deleteHabitAlert(habit: $habitToDelete) { habit in
            appContainer.habitService.delete(habit)
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if archivedHabits.isEmpty {
            ContentUnavailableView(
                "No Archived Habits",
                systemImage: "archivebox.fill",
                description: Text("Archived habits will appear here")
            )
            .listRowBackground(Color.clear)
        } else {
            ForEach(archivedHabits) { habit in
                archivedHabitRow(habit)
            }
        }
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
            .buttonBorderShape(.circle)

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
