import SwiftUI
import SwiftData

// MARK: - Habit Row
struct HabitRow: View {
    let viewModel: HabitsViewModel
    let habit: Habit
    let date: Date

    @Environment(TimerService.self) private var timerService

    var body: some View {
        HStack(spacing: Spacing.sm) {
            HabitIconView(icon: habit.iconName, color: habit.iconColor)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(habit.title)
                    .font(.headline)

                Text("\(habit.formatProgress(cardProgress)) | \(habit.formattedGoal)")
                    .font(.subheadline).monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(Animations.bouncy, value: cardProgress)
            }
            .foregroundStyle(.appPrimary)
            .lineLimit(1)

            Spacer()

            Button {
                viewModel.handleRingTap(on: habit, date: date)
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
        .padding(.horizontal, Spacing.reg)
        .padding(.vertical, Spacing.sm)
        .onChange(of: timerService.updateTrigger) { _, _ in
            if isTimerActive {
                viewModel.checkCompletionForActiveTimer(habit, date: date)
            }
        }
    }

    // MARK: - Computed Properties

    private var isTimerActive: Bool {
        guard habit.modelContext != nil,
              habit.type == .time,
              Calendar.current.isDateInToday(date)
        else { return false }
        return timerService.isTimerRunning(for: habit.uuid.uuidString)
    }

    private var cardProgress: Int {
        _ = timerService.updateTrigger
        return viewModel.getEffectiveProgress(for: habit, on: date)
    }

    private var cardCompletionPercentage: Double {
        guard habit.goal > 0 else { return 0 }
        return Double(cardProgress) / Double(habit.goal)
    }
}

// MARK: - HabitCard

struct HabitCard: View {
    let viewModel: HabitsViewModel
    let habit: Habit
    let date: Date
    var onEdit: () -> Void

    @State private var habitToDelete: Habit?

    private let cardShape = RoundedRectangle(cornerRadius: Radius.lg)
    private let cardPreview = RoundedRectangle(cornerRadius: Radius.md)
    private let contextMenuTint: Color = .appPrimary

    private var isSkipped: Bool { viewModel.isHabitSkipped(habit, on: date) }

    var body: some View {
        HabitRow(
            viewModel: viewModel,
            habit: habit,
            date: date
        )
        .glassEffect(.regular, in: cardShape)
        .contentShape(cardShape)
        .contentShape(.contextMenuPreview, cardPreview)
        .contextMenu {
            skipButton
            editButton
            archiveButton
            Divider()
            deleteButton
        }
        .deleteHabitAlert(habit: $habitToDelete) { habit in
            viewModel.deleteHabit(habit)
        }
    }

    // MARK: - Context Menu

    private var skipButton: some View {
        Button {
            viewModel.toggleSkip(for: habit, date: date)
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
            onEdit()
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(contextMenuTint)
    }

    private var archiveButton: some View {
        Button {
            viewModel.archiveHabit(habit)
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
