import SwiftUI
import SwiftData

struct HabitsReorderView: View {
    let vm: HabitsViewModel
    let selectedDate: Date

    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var selection = Set<Habit>()
    @State private var editMode: EditMode = .active

    private let cardPreview = RoundedRectangle(cornerRadius: DS.Spacing.md)
    private let iconSize = DS.IconSize.sm

    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                ForEach(allHabits.filter { !$0.isArchived }) { habit in
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
                    }
                    .tag(habit)
                }
                .onMove { source, destination in
                    vm.moveHabits(from: source, to: destination, date: selectedDate)
                }
                .rowBackground()
            }
            .navigationTitle("Reorder")
            .environment(\.editMode, $editMode)
            .toolbar { CloseToolbarButton { dismiss() } }
            .safeAreaBar(edge: .bottom) {
                actionButtons
                    .disabled(selection.isEmpty)
                    .animation(DS.Animations.easeInOut, value: selection.isEmpty)
            }
        }
        .appBackground(.grouped)
    }

    private var actionButtons: some View {
        HStack(spacing: DS.Spacing.md) {
            Button {
                archiveSelected()
            } label: {
                Label("Archive", systemImage: "archivebox")
                    .padding(DS.Spacing.xs)
            }
            .buttonStyle(.glass)

            Spacer()

            Button(role: .destructive) {
                deleteSelected()
            } label: {
                Label("Delete", systemImage: "trash")
                .padding(DS.Spacing.xs)
            }
            .tint(.red)
            .buttonStyle(.glass)
        }
        .padding(DS.Spacing.reg)
    }

    private func deleteSelected() {
        withAnimation {
            for habit in selection {
                appContainer.habitService.delete(habit)
            }
            selection.removeAll()
        }
    }

    private func archiveSelected() {
        withAnimation {
            for habit in selection {
                appContainer.habitService.archive(habit)
            }
            selection.removeAll()
        }
    }
}
