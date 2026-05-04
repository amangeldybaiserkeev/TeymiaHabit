import SwiftUI
import SwiftData

// MARK: - HabitListRow

struct HabitListRow: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(HabitsViewModel.self) private var vm

    let habit: Habit
    let date: Date

    // MARK: - Computed Properties

    private var isTimerActive: Bool {
        guard habit.modelContext != nil,
              habit.type == .time,
              Calendar.current.isDateInToday(date)
        else { return false }
        return appContainer.timerService.isTimerRunning(for: habit.uuid.uuidString)
    }

    private var cardProgress: Int {
        guard habit.modelContext != nil else { return 0 }

        if let tempValue = vm.temporaryProgress[habit.uuid] {
            return tempValue
        }

        // Reading updateTrigger subscribes this view to timer ticks
        _ = appContainer.timerService.updateTrigger

        if isTimerActive {
            return appContainer.timerService.getLiveProgress(for: habit.uuid.uuidString)
                ?? habit.progressForDate(date)
        }

        return habit.progressForDate(date)
    }

    private var cardCompletionPercentage: Double {
        guard habit.goal > 0 else { return 0 }
        return Double(cardProgress) / Double(habit.goal)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            HabitIconView(iconName: habit.iconName, color: habit.actualColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)

                Text("\(habit.formatProgress(cardProgress)) | \(habit.formattedGoal)")
                    .font(.subheadline).monospacedDigit()
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                    .animation(.spring, value: cardProgress)
            }
            .foregroundStyle(.primary)
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
}

// MARK: - HabitCard

struct HabitCard: View {
    @Environment(HabitsViewModel.self) private var vm

    let habit: Habit
    let date: Date
    var onEdit: (() -> Void)?

    @State private var habitToDelete: Habit?

    private let cardShape = RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)

    private var isSkipped: Bool { habit.isSkipped(on: date) }

    var body: some View {
        HabitListRow(habit: habit, date: date)
            .glassEffect(.regular, in: cardShape)
            .contentShape(cardShape)
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
                isSkipped ? "unskip" : "skip",
                systemImage: isSkipped ? "arrow.left" : "arrow.right"
            )
        }
        .tint(.primary)
    }

    private var editButton: some View {
        Button {
            onEdit?()
        } label: {
            Label("button_edit", systemImage: "pencil")
        }
        .tint(.primary)
    }

    private var archiveButton: some View {
        Button {
            vm.archiveHabit(habit)
        } label: {
            Label("archive", systemImage: "archivebox")
        }
        .tint(.primary)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            habitToDelete = habit
        } label: {
            Label("button_delete", systemImage: "trash")
        }
        .tint(.red)
    }
}
