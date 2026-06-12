import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(HabitService.self) private var habitService
    @Environment(TimerService.self) private var timerService
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(SoundManager.self) private var soundManager

    @State private var viewModel: HabitDetailViewModel?
    @State private var isEditPresented = false
    @State private var showingStats = false
    @State private var habitToDelete: Habit?

    private var isSkipped: Bool { habit.isSkipped(on: date) }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    mainContent(vm: viewModel)
                        .toolbar {
                            DismissToolbarButton()

                            ToolbarItem(placement: .topBarLeading) {
                                if !Calendar.current.isDateInToday(date) {
                                    Text(date.formattedAsNavigationTitle())
                                        .foregroundStyle(.appSecondary)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .sharedBackgroundVisibility(.hidden)

                            ToolbarItem(placement: .topBarTrailing) {
                                menuButton(vm: viewModel)
                            }
                        }
                        .deleteHabitAlert(habit: $habitToDelete) { _ in
                            viewModel.deleteHabit()
                            dismiss()
                        }
                        .id(habit.uuid.uuidString)
                        .onDisappear {
                            viewModel.prepareForDeletion()
                        }
                        .onChange(of: date) { _, newDate in
                            viewModel.updateDisplayedDate(newDate)
                        }
                        .sheet(isPresented: $isEditPresented) {
                            NewHabitView(habit: habit)
                        }
                        .sheet(isPresented: $showingStats) {
                            HabitStatisticsView(habit: habit)
                        }
                }
            }
            .task {
                guard viewModel == nil else { return }
                viewModel = HabitDetailViewModel(
                    habit: habit,
                    initialDate: date,
                    habitService: habitService,
                    timerService: timerService,
                    notificationManager: notificationManager,
                    soundManager: soundManager
                )
            }
        }
    }

    @ViewBuilder
    private func mainContent(vm: HabitDetailViewModel) -> some View {
        VStack(spacing: Spacing.xl) {
            habitTitle(vm: vm)
            progressRing(vm: vm)
            actionButtonsRow(vm: vm)
            completeButtonView(vm: vm)
                .padding(.bottom, Spacing.sm)
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private func habitTitle(vm: HabitDetailViewModel) -> some View {
        VStack(alignment: .center, spacing: Spacing.xxs) {
            Text(habit.title)
                .font(.title)
            Text("Goal: \(habit.formattedGoal)")
                .font(.subheadline)
                .foregroundStyle(.appSecondary)
        }
    }

    @ViewBuilder
    private func progressRing(vm: HabitDetailViewModel) -> some View {
        HStack(spacing: Spacing.xxl) {
            ProgressIconButton(
                systemName: "minus",
                action: {
                    withAnimation(Animations.easeInOut) {
                        vm.decrementProgress()
                    }
                },
                isDisabled: vm.currentProgress <= 0
            )

            ProgressRing(
                progress: vm.completionPercentage,
                currentValue: "\(vm.currentProgress)",
                isCompleted: vm.isAlreadyCompleted,
                isExceeded: vm.currentProgress > habit.goal,
                habit: habit,
                size: 170
            )

            ProgressIconButton(
                systemName: "plus",
                action: {
                    withAnimation(Animations.easeInOut) {
                        vm.incrementProgress()
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func actionButtonsRow(vm: HabitDetailViewModel) -> some View {
        HStack(spacing: Spacing.xxl) {
            Button {
                withAnimation(Animations.easeInOut) {
                    vm.resetProgress()
                }
            } label: {
                Image(systemName: "minus.arrow.trianglehead.counterclockwise")
                    .font(.system(size: IconSize.reg, weight: .medium))
                    .foregroundStyle(.appPrimary)
                    .frame(size: TouchTarget.comfortable)
                    .background(.appSecondary.opacity(0.1), in: .circle)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)

            PopoverView {
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .font(.system(size: IconSize.reg, weight: .medium))
                    .foregroundStyle(.appPrimary)
                    .frame(size: TouchTarget.comfortable)
                    .background(.appSecondary.opacity(0.1), in: .circle)
                    .contentShape(.circle)
            } content: {
                DayProgressPopover(habit: habit, date: date, onAddProgress: vm.addProgress)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func completeButtonView(vm: HabitDetailViewModel) -> some View {
        Button {
            withAnimation(Animations.easeInOut) {
                if habit.type == .time && Calendar.current.isDateInToday(date) {
                    vm.toggleTimer()
                } else {
                    vm.completeHabit()
                }
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                if habit.type == .time && Calendar.current.isDateInToday(date) {
                    Image(systemName: vm.isTimerRunning ? "pause.fill" : "play.fill")
                        .contentTransition(.symbolEffect(.replace))
                }

                Text(buttonLabel(vm: vm))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.isTimerRunning)
                    .animation(.snappy, value: vm.isAlreadyCompleted)
            }
            .font(.headline)
            .foregroundStyle(.primaryButtonText)
            .frame(maxWidth: 400, minHeight: TouchTarget.large)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive().tint(.primaryButton), in: .capsule)
        .disabled(habit.type == .count && vm.isAlreadyCompleted)
    }

    private func buttonLabel(vm: HabitDetailViewModel) -> LocalizedStringKey {
        if habit.type == .time && Calendar.current.isDateInToday(date) {
            return vm.isTimerRunning ? "Stop Timer" : "Start Timer"
        }
        return vm.isAlreadyCompleted ? "Completed" : "Complete"
    }

    @ViewBuilder
    private func menuButton(vm: HabitDetailViewModel) -> some View {
        Menu {
            Button {
                vm.toggleSkip()
            } label: {
                Label(
                    isSkipped ? "Unskip" : "Skip",
                    systemImage: isSkipped ? "arrow.left" : "arrow.right"
                )
            }

            Button {
                isEditPresented = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                vm.archiveHabit()
                dismiss()
            } label: {
                Label("Archive", systemImage: "archivebox")
            }

            Divider()

            Button(role: .destructive) {
                habitToDelete = habit
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.appPrimary)
        }
        .menuOrder(.fixed)
        .tint(.appPrimary)
    }
}

private struct ProgressIconButton: View {
    let systemName: String
    let action: () -> Void
    var isDisabled: Bool = false

    @State private var haptic = 0

    var body: some View {
        Button {
            action()
            haptic += 1
        } label: {
            Image(systemName: systemName)
                .font(.system(size: IconSize.reg, weight: .medium))
                .foregroundStyle(Color.primary)
                .frame(size: TouchTarget.comfortable)
                .background(Color.secondary.opacity(0.1), in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .sensoryFeedback(.selection, trigger: haptic)
    }
}
