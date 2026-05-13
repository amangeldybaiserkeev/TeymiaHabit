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

    static let backgroundColors: [Color] = [
        Color(#colorLiteral(red: 0.1389154494, green: 0.1585697234, blue: 0.1820063889, alpha: 1)), Color(#colorLiteral(red: 0.1131844893, green: 0.1154304668, blue: 0.1189380512, alpha: 1)), Color(#colorLiteral(red: 0.1128983721, green: 0.1153769568, blue: 0.1175429896, alpha: 1)), Color(#colorLiteral(red: 0.1898193061, green: 0.1917725205, blue: 0.1859131753, alpha: 1)), Color(#colorLiteral(red: 0.3071291447, green: 0.2973631024, blue: 0.2744144797, alpha: 1)),
        Color(#colorLiteral(red: 0.08233620971, green: 0.08233659714, blue: 0.09095162898, alpha: 1)), Color(#colorLiteral(red: 0.1359860003, green: 0.1458741426, blue: 0.162841469, alpha: 1)), Color(#colorLiteral(red: 0.2690429091, green: 0.271240294, blue: 0.2695312202, alpha: 1)), Color(#colorLiteral(red: 0.1608034074, green: 0.1646784544, blue: 0.1881882548, alpha: 1)), Color(#colorLiteral(red: 0.08221431822, green: 0.08221431822, blue: 0.08221431822, alpha: 1))
    ]

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HabitDetailViewModel
    @State private var showingStats  = false
    @State private var isEditPresented = false
    @State private var habitToDelete: Habit?
    @State private var haptic = 0
    @State private var currentBgColor: Color = Self.backgroundColors.randomElement() ?? .black

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
                .background(currentBgColor.gradient)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if !Calendar.current.isDateInToday(date) {
                            Text(date.formattedAsNavigationTitle())
                                .foregroundStyle(DS.Colors.secondary)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
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

    // MARK: - Content

    @ViewBuilder
    private func mainContent(vm: HabitDetailViewModel) -> some View {
            VStack(spacing: 0) {
                Capsule()
                    .fill(.white.opacity(0.4))
                    .frame(width: 60, height: 5)
                    .padding(.vertical, DS.Spacing.xs)

                Spacer(minLength: DS.Spacing.xl)

                ProgressRing(
                    progress: vm.completionPercentage,
                    currentValue: "\(vm.currentProgress)",
                    isCompleted: vm.isAlreadyCompleted,
                    isExceeded: vm.currentProgress > habit.goal,
                    habit: habit,
                    size: 240,
                    lineWidth: 26
                )
                .padding(.vertical, DS.Spacing.xxl)

                Spacer(minLength: DS.Spacing.xl)

                habitTitle(vm: vm)

                Spacer(minLength: DS.Spacing.xl)

                actionButtonsRow(vm: vm)

                Spacer(minLength: DS.Spacing.reg)

                completeButtonView(vm: vm)
                .padding(.bottom, DS.Spacing.xxl)
            }
            .padding(.horizontal, DS.Spacing.xl)
    }

    @ViewBuilder
    private func habitTitle(vm: HabitDetailViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(habit.title)
                    .font(DS.AppFont.title2)
                Text("Goal: \(habit.formattedGoal)")
                    .font(DS.AppFont.subheadline)
                    .foregroundStyle(DS.Colors.secondary)
            }

            Spacer()

            HStack(spacing: DS.Spacing.reg) {
                if showStatsButton {
                        Button {
                            showingStats = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: DS.IconSize.xs))
                                .frame(size: DS.IconSize.lg)
                                .background {
                                    Circle()
                                        .fill(.white.opacity(0.1))
                                }
                        }
                        .tint(DS.Colors.primary)
                }

                menuButton(vm: vm)
            }
        }
    }

    // MARK: - Menu

    @ViewBuilder
    private func menuButton(vm: HabitDetailViewModel) -> some View {
        Menu {
            Button(role: .destructive) {
                habitToDelete = habit
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)

            Divider()

            Button {
                vm.archiveHabit()
                dismiss()
            } label: {
                Label("Archive", systemImage: "archivebox")
            }

            Button {
                isEditPresented = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: DS.IconSize.xs, weight: .bold))
                .frame(size: DS.IconSize.lg)
                .background {
                    Circle()
                        .fill(.white.opacity(0.1))
                }
        }
        .preferredColorScheme(.dark)
        .tint(DS.Colors.primary)
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
                    .contentShape(.circle)
            }
            .glassEffect(.clear.interactive(), in: .capsule)

            ProgressIconButton(
                systemName: "minus",
                action: {
                    withAnimation(DS.Animations.easeInOut) {
                        vm.decrementProgress()
                    }
                },
                isDisabled: vm.currentProgress <= 0
            )

            ProgressIconButton(
                systemName: "plus",
                action: {
                    withAnimation(DS.Animations.easeInOut) {
                        vm.incrementProgress()
                    }
                }
            )

            PopoverView {
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .font(.system(size: DS.IconSize.reg, weight: .medium))
                    .foregroundStyle(DS.Colors.primary)
                    .frame(size: DS.TouchTarget.comfortable)
                    .contentShape(.circle)
            } content: {
                DayProgressPopover(habit: habit, date: date, onAddProgress: vm.addProgress)
            }
            .glassEffect(.clear.interactive(), in: .capsule)
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
            .foregroundStyle(DS.Colors.primary)
            .frame(maxWidth: .infinity, minHeight: DS.TouchTarget.large)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .capsule)
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
            haptic += 1
            return .handled
        }
    }

    private func buttonLabel(vm: HabitDetailViewModel) -> LocalizedStringKey {
        if habit.type == .time && Calendar.current.isDateInToday(date) {
            return vm.isTimerRunning ? "Stop Timer" : "Start Timer"
        }
        return vm.isAlreadyCompleted ? "Completed" : "Complete"
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
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .circle)
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
