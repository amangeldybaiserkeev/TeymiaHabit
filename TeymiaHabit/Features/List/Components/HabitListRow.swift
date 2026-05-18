import SwiftUI
import SwiftData

// MARK: - HabitListRow

struct HabitListRow: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(HabitsViewModel.self) private var vm

    let habit: Habit
    let date: Date

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            HabitIconView(iconName: habit.iconName, color: habit.iconColor.baseColor)

            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(habit.title)
                    .font(DS.AppFont.headline)

                Text("\(habit.formatProgress(cardProgress)) | \(habit.formattedGoal)")
                    .font(DS.AppFont.subheadline).monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(DS.Animations.bouncy, value: cardProgress)
            }
            .foregroundStyle(DS.Colors.primary)
            .lineLimit(1)

            Spacer()

            Button {
                vm.handleRingTap(on: habit, date: date)
            } label: {
                ProgressRing(
                    progress: cardCompletionPercentage,
                    currentValue: "",
                    isCompleted: cardProgress >= habit.goal,
                    isExceeded: cardProgress > habit.goal,
                    habit: habit,
                    size: 50,
                    isTimerRunning: isTimerActive
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DS.Spacing.reg)
        .padding(.vertical, DS.Spacing.sm)
        .onChange(of: appContainer.timerService.updateTrigger) { _, _ in
            if isTimerActive {
                vm.checkCompletionForActiveTimer(habit, date: date)
            }
        }
    }

    // MARK: - Computed Properties

    private var isTimerActive: Bool {
        guard habit.modelContext != nil,
              habit.type == .time,
              Calendar.current.isDateInToday(date)
        else { return false }
        return appContainer.timerService.isTimerRunning(for: habit.uuid.uuidString)
    }

    private var cardProgress: Int {
        _ = appContainer.timerService.updateTrigger

        return vm.getEffectiveProgress(for: habit, on: date)
    }

    private var cardCompletionPercentage: Double {
        guard habit.goal > 0 else { return 0 }
        return Double(cardProgress) / Double(habit.goal)
    }
}

// MARK: - HabitCard

struct HabitCard: View {
    @Environment(HabitsViewModel.self) private var vm

    let habit: Habit
    let date: Date
    var onEdit: (() -> Void)?

    @State private var habitToDelete: Habit?

    private let cardShape = RoundedRectangle(cornerRadius: DS.Radius.lg)
    private let cardPreview = RoundedRectangle(cornerRadius: DS.Radius.md)
    private let contextMenuTint = DS.Colors.primary

    private var isSkipped: Bool { habit.isSkipped(on: date) }

    var body: some View {
        HabitListRow(
            habit: habit,
            date: date
        )
        .glassEffect(.regular.tint(DS.Colors.rowBackground), in: cardShape)
        .contentShape(cardShape)
        .contentShape(.dragPreview, cardPreview)
        .contentShape(.contextMenuPreview, cardPreview)
        .contextMenu {
            skipButton
            editButton
            archiveButton
            Divider()
            deleteButton
        }
        .deleteHabitAlert(habit: $habitToDelete) { habit in
            vm.deleteHabit(habit)
        }
    }

    // MARK: - Context Menu

    private var skipButton: some View {
        Button {
            vm.toggleSkip(for: habit, date: date)
        } label: {
            Label(
                isSkipped ? "Unskip" : "Skip",
                systemImage: isSkipped ? "arrow.left" : "arrow.right"
            )
        }
        .tint(contextMenuTint)
    }

    private var editButton: some View {
        Button {
            onEdit?()
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(contextMenuTint)
    }

    private var archiveButton: some View {
        Button {
            vm.archiveHabit(habit)
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        .tint(contextMenuTint)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            habitToDelete = habit
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
}
