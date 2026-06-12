import SwiftUI
import SwiftData

// MARK: - HabitsView (reads environment, passes to content)

struct HabitsView: View {
    @Binding var selectedDate: Date

    @Environment(HabitService.self) private var habitService
    @Environment(SoundManager.self) private var soundManager
    @Environment(TimerService.self) private var timerService
    @Environment(StoreKitService.self) private var storeKitService

    var body: some View {
        HabitsContentView(
            selectedDate: $selectedDate,
            habitService: habitService,
            soundManager: soundManager,
            timerService: timerService,
            storeKitService: storeKitService
        )
    }
}

// MARK: - HabitsContentView (owns ViewModel, @Query)

private struct HabitsContentView: View {
    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    @Binding var selectedDate: Date

    @State private var viewModel: HabitsViewModel
    @State private var selectedHabit: Habit?
    @State private var habitToEdit: Habit?
    @State private var showingNewHabit = false
    @State private var showingPaywall = false

    private let storeKitService: StoreKitService

    @Namespace private var namespace

    init(
        selectedDate: Binding<Date>,
        habitService: HabitService,
        soundManager: SoundManager,
        timerService: TimerService,
        storeKitService: StoreKitService
    ) {
        _selectedDate = selectedDate
        self.storeKitService = storeKitService
        _viewModel = State(wrappedValue: HabitsViewModel(
            habitService: habitService,
            soundManager: soundManager,
            timerService: timerService
        ))
    }

    var body: some View {
        Group {
            if viewModel.activeHabits(for: selectedDate).isEmpty {
                HabitsEmptyView { showingNewHabit = true }
            } else {
                habitsList
            }
        }
        .onChange(of: allHabits, initial: true) { _, habits in
            viewModel.allBaseHabits = habits
        }
        .fullScreenCover(isPresented: $showingNewHabit) {
            TemplatesView()
                .navigationTransition(.zoom(sourceID: TransitionID.listToTemplates, in: namespace))
        }
        .sheet(item: $habitToEdit) { habit in
            NewHabitView(habit: habit)
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit, date: selectedDate)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private var habitsList: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.sm) {
                    WeeklyCalendarView(selectedDate: $selectedDate)

                    ForEach(viewModel.activeHabits(for: selectedDate)) { habit in
                        HabitCard(
                            viewModel: viewModel,
                            habit: habit,
                            date: selectedDate,
                            onEdit: { habitToEdit = habit }
                        )
                        .onTapGesture {
                            selectedHabit = habit
                        }
                    }
                    .padding(.horizontal, Spacing.reg)
                }
            }
            .navigationTitle(selectedDate.formattedAsNavigationTitle())
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar { toolbarContent }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !Calendar.current.isDateInToday(selectedDate) {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedDate = Date()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                }
                .tint(.appPrimary)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                if viewModel.allBaseHabits.count < storeKitService.maxHabitsCount {
                    showingNewHabit = true
                } else {
                    showingPaywall = true
                }
            } label: {
                Image(systemName: "plus")
                    .matchedTransitionSource(id: TransitionID.listToTemplates, in: namespace)
            }
            .tint(.appPrimary)
        }
    }
}

// MARK: - HabitsEmptyView

private struct HabitsEmptyView: View {
    let action: () -> Void
    private let iconSize = IconSize.reg

    var body: some View {
        EmptyStateView(
            title: "No habits yet",
            message: message,
            buttonTitle: "Build new Habits",
            action: action,
            footerText: "Join millions building better habits"
        ) {
            HStack(spacing: Spacing.md) {
                Icon(name: "book.person.fill")
                Icon(name: "massage.fill")
                Icon(name: "person.swimmer.fill")
            }
        }
    }

    private var message: String {
        "Start small: add a habit like 'Read a book 15 minutes' or 'Morning walk'. " +
        "Watch how consistency creates real change over time."
    }

    @ViewBuilder
    private func Icon(name: String) -> some View {
        Image(name)
            .resizable()
            .frame(size: iconSize)
            .frame(size: iconSize * 1.8)
            .foregroundStyle(.appSecondary)
            .background(.appTertiary, in: .circle)
    }
}
