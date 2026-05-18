import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date
    @State private var vm: HabitsViewModel

    init(selectedDate: Binding<Date>, appContainer: AppDependencyContainer, modelContext: ModelContext) {
        self._selectedDate = selectedDate
        self._vm = State(wrappedValue: HabitsViewModel(
            modelContext: modelContext,
            habitService: appContainer.habitService,
            notificationManager: appContainer.notificationManager,
            soundManager: appContainer.soundManager,
            widgetService: appContainer.widgetService,
            timerService: appContainer.timerService
        ))
    }

    var body: some View {
        HabitsContentView(vm: vm, selectedDate: $selectedDate)
    }
}

// MARK: - Content View

struct HabitsContentView: View {
    let vm: HabitsViewModel

    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Binding var selectedDate: Date

    @State private var selectedHabit: Habit?
    @State private var showingNewHabit = false
    @State private var habitToEdit: Habit?
    @State private var showingManagement = false

    var body: some View {
        Group {
            if !allHabits.contains(where: { !$0.isArchived }) {
                HabitsEmptyView { showingNewHabit = true }
            } else {
                habitsList
            }
        }
        .appBackground()
        .onChange(of: allHabits, initial: true) { _, newValue in
            vm.allBaseHabits = newValue
        }
        .sheet(isPresented: $showingNewHabit) {
            NewHabitView()
        }
        .sheet(item: $habitToEdit) { habit in
            NewHabitView(habit: habit)
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit, date: selectedDate)
        }
        .sheet(isPresented: $showingManagement) {
            HabitsReorderView(vm: vm, selectedDate: selectedDate)
        }
        .onChange(of: appContainer.navManager.habitToOpen) { _, habit in
            guard let habit else { return }
            selectedHabit = habit
            appContainer.navManager.habitToOpen = nil
        }
        .sensoryFeedback(.selection, trigger: showingNewHabit)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .cancellationAction) {
            if !vm.allBaseHabits.isEmpty {
                Button {
                    showingManagement = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
                .tint(DS.Colors.primary)
            }
        }

        if !Calendar.current.isDateInToday(selectedDate) {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    selectedDate = Date()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                }
                .tint(DS.Colors.primary)
            }
        }

        ToolbarSpacer(.fixed, placement: .confirmationAction)

        ToolbarItem(placement: .confirmationAction) {
            Button {
                if allHabits.count < appContainer.storeKitService.maxHabitsCount {
                    showingNewHabit = true
                } else {
                    appContainer.showingPaywall = true
                }
            } label: {
                Image(systemName: "plus")
            }
            .tint(DS.Colors.primary)
        }
    }

    // MARK: - Habits List

    private var habitsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            habitListContent
                .applyAdaptiveWidth()
        }
        .environment(vm)
        .navigationTitle(vm.navigationTitle(for: selectedDate))
        .toolbar { toolbarContent }
    }

    @ViewBuilder
    private var habitListContent: some View {
        LazyVStack(spacing: DS.Spacing.sm) {
            WeeklyCalendarView(selectedDate: $selectedDate, vm: vm)

            ForEach(vm.activeHabits(for: selectedDate)) { habit in
                HabitCard(
                    habit: habit,
                    date: selectedDate,
                    onEdit: { habitToEdit = habit }
                )
                .padding(.horizontal, DS.Spacing.reg)
                .tag(habit)
                .opacity(habit.isSkipped(on: selectedDate) ? 0.4 : 1.0)
                .onTapGesture {
                    selectedHabit = habit
                }
            }
        }
        .padding(.vertical, DS.Spacing.reg)
    }
}

// MARK: - HabitsEmptyView

private struct HabitsEmptyView: View {
    let action: () -> Void
    private let iconSize = DS.IconSize.reg

    var body: some View {
        EmptyStateView(
            title: "No habits yet",
            message: message,
            buttonTitle: "Build new Habits",
            action: action,
            footerText: "Join millions building better habits"
        ) {
            HStack(spacing: DS.Spacing.md) {
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
            .foregroundStyle(DS.Colors.secondary)
            .background(DS.Colors.tertiary, in: .circle)
    }
}
