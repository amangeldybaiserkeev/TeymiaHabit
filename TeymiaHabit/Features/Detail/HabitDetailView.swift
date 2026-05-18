import SwiftUI
import SwiftData

// MARK: - Entry Point

struct HabitDetailView: View {
    @Environment(AppDependencyContainer.self) private var appContainer

    let habit: Habit
    let date: Date
    let showStatsButton: Bool

    init(habit: Habit, date: Date, showStatsButton: Bool = true) {
        self.habit = habit
        self.date = date
        self.showStatsButton = showStatsButton
    }

    var body: some View {
        HabitDetailContentView(
            habit: habit,
            date: date,
            viewModel: HabitDetailViewModel(
                habit: habit,
                initialDate: date,
                habitService: appContainer.habitService,
                timerService: appContainer.timerService,
                widgetService: appContainer.widgetService,
                notificationManager: appContainer.notificationManager,
                soundManager: appContainer.soundManager,
                habitLiveActivityManager: appContainer.habitLiveActivityManager
            ),
            showStatsButton: showStatsButton
        )
    }
}

// MARK: - Content View

struct HabitDetailContentView: View {
    let habit: Habit
    let date: Date
    let showStatsButton: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var viewModel: HabitDetailViewModel
    @State private var showingStats  = false
    @State private var isEditPresented = false
    @State private var habitToDelete: Habit?
    @State private var haptic = 0
    private var isSkipped: Bool { habit.isSkipped(on: date) }

    init(
        habit: Habit,
        date: Date,
        viewModel: HabitDetailViewModel,
        showStatsButton: Bool = true
    ) {
        self.habit = habit
        self.date = date
        self.showStatsButton = showStatsButton
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            mainContent(vm: viewModel)
                .sensoryFeedback(.selection, trigger: haptic)
                .toolbar {
#if targetEnvironment(macCatalyst)
                    CloseToolbarButton {
                        dismiss()
                    }
#endif

                    ToolbarItem(placement: .topBarLeading) {
                        if !Calendar.current.isDateInToday(date) {
                            Text(date.formattedAsNavigationTitle())
                                .foregroundStyle(DS.Colors.secondary)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if showStatsButton {
                                Button {
                                    showingStats = true
                                } label: {
                                    Image(systemName: "chart.bar.fill")
                                        .imageScale(.small)
                                        .foregroundStyle(DS.Colors.primary)
                                }
                        }

                        menuButton(vm: vm)
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
                        .environment(appContainer)
                }
                .sheet(isPresented: $showingStats) {
                    HabitStatisticsView(habit: habit)
                }
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Content

    @ViewBuilder
    private func mainContent(vm: HabitDetailViewModel) -> some View {
        VStack(spacing: DS.Spacing.xl) {
            habitTitle(vm: vm)
            progressRing(vm: vm)
            actionButtonsRow(vm: vm)
            completeButtonView(vm: vm)
                .padding(.bottom, DS.Spacing.sm)
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    @ViewBuilder
    private func habitTitle(vm: HabitDetailViewModel) -> some View {
            VStack(alignment: .center, spacing: DS.Spacing.xxs) {
                Text(habit.title)
                    .font(DS.AppFont.title)
                Text("Goal: \(habit.formattedGoal)")
                    .font(DS.AppFont.subheadline)
                    .foregroundStyle(DS.Colors.secondary)
            }
    }

    @ViewBuilder
    private func progressRing(vm: HabitDetailViewModel) -> some View {
        HStack(spacing: DS.Spacing.xxl) {
            ProgressIconButton(
                systemName: "minus",
                action: {
                    withAnimation(DS.Animations.easeInOut) {
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
                    withAnimation(DS.Animations.easeInOut) {
                        vm.incrementProgress()
                    }
                }
            )

        }
    }

    // MARK: - Actions

    @ViewBuilder
    private func actionButtonsRow(vm: HabitDetailViewModel) -> some View {
        HStack(spacing: DS.Spacing.xxl) {
            Button {
                withAnimation(DS.Animations.easeInOut) {
                    vm.resetProgress()
                }
                haptic += 1
            } label: {
                Image(systemName: "minus.arrow.trianglehead.counterclockwise")
                    .font(.system(size: DS.IconSize.reg, weight: .medium))
                    .foregroundStyle(DS.Colors.primary)
                    .frame(size: DS.TouchTarget.comfortable)
                    .background(DS.Colors.secondary.opacity(0.1), in: .circle)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)

            PopoverView {
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .font(.system(size: DS.IconSize.reg, weight: .medium))
                    .foregroundStyle(DS.Colors.primary)
                    .frame(size: DS.TouchTarget.comfortable)
                    .background(DS.Colors.secondary.opacity(0.1), in: .circle)
                    .contentShape(.circle)
            } content: {
                DayProgressPopover(habit: habit, date: date, onAddProgress: vm.addProgress)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Complete

    @ViewBuilder
    private func completeButtonView(vm: HabitDetailViewModel) -> some View {
        Button {
            withAnimation(DS.Animations.easeInOut) {
                if habit.type == .time && Calendar.current.isDateInToday(date) {
                    vm.toggleTimer()
                } else {
                    vm.completeHabit()
                }
            }
            haptic += 1
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                if habit.type == .time && Calendar.current.isDateInToday(date) {
                    Image(systemName: vm.isTimerRunning ? "pause.fill" : "play.fill")
                        .contentTransition(.symbolEffect(.replace))
                }

                Text(buttonLabel(vm: vm))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.isTimerRunning)
                    .animation(.snappy, value: vm.isAlreadyCompleted)
            }
            .font(DS.AppFont.headline)
            .foregroundStyle(DS.Colors.primaryButtonText)
            .frame(maxWidth: 400, minHeight: DS.TouchTarget.large)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive().tint(DS.Colors.primaryButton), in: .capsule)
        .disabled(habit.type == .count && vm.isAlreadyCompleted)
        .focusable()
        .onKeyPress(keys: [.space]) { _ in
            withAnimation(DS.Animations.easeInOut) {
                if habit.type == .time && Calendar.current.isDateInToday(date) {
                    vm.toggleTimer()
                } else {
                    vm.completeHabit()
                }
            }
            return .handled
        }
    }

    private func buttonLabel(vm: HabitDetailViewModel) -> LocalizedStringKey {
        if habit.type == .time && Calendar.current.isDateInToday(date) {
            return vm.isTimerRunning ? "Stop Timer" : "Start Timer"
        }
        return vm.isAlreadyCompleted ? "Completed" : "Complete"
    }

    // MARK: - Menu

    @ViewBuilder
    private func menuButton(vm: HabitDetailViewModel) -> some View {
        Menu {
            Button {
                vm.toggleSkip(for: habit, date: date)
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
                .foregroundStyle(DS.Colors.primary)
        }
        .menuOrder(.fixed)
        .tint(DS.Colors.primary)
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
                .font(.system(size: DS.IconSize.reg, weight: .medium))
                .foregroundStyle(DS.Colors.primary)
                .frame(size: DS.TouchTarget.comfortable)
                .background(DS.Colors.secondary.opacity(0.1), in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .sensoryFeedback(.selection, trigger: haptic)
    }
}

#Preview {
    let container = PreviewContainer.container
    let appContainer = PreviewContainer.appContainer

    let habit = Habit(
        title: "Read Books",
        type: .time,
        goal: 10,
        iconName: "book.fill",
        iconColor: .colorPicker
    )
    container.mainContext.insert(habit)

    return HabitDetailView(habit: habit, date: .now)
        .environment(appContainer)
        .modelContainer(container)
}
