import SwiftUI
import SwiftData

// MARK: - Entry Point
//
// HabitsView receives appContainer explicitly from MainTabView where @Environment
// is already resolved. This is the correct SwiftUI pattern for initializing
// @Observable ViewModels that depend on environment values — @Environment is not
// available during View.init(), only during body evaluation.

struct HabitsView: View {
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
        HabitsContentView(selectedDate: $selectedDate, vm: vm)
    }
}

// MARK: - Content View

struct HabitsContentView: View {
    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    @Environment(AppDependencyContainer.self) private var appContainer

    @Binding var selectedDate: Date
    @State private var vm: HabitsViewModel
    @State private var isEditMode: EditMode = .inactive
    @State private var selectedHabit: Habit?
    @State private var showingNewHabit = false
    @State private var habitToEdit: Habit?

    init(selectedDate: Binding<Date>, vm: HabitsViewModel) {
        self._selectedDate = selectedDate
        self._vm = State(wrappedValue: vm)
    }

    var body: some View {
        Group {
            if allHabits.isEmpty {
                emptyView
            } else {
                habitsList
            }
        }
        .onChange(of: allHabits, initial: true) { _, newValue in
            Task { @MainActor in
                vm.allBaseHabits = newValue
            }
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
        .onChange(of: appContainer.navManager.habitToOpen) { _, habit in
            guard let habit else { return }
            selectedHabit = habit
            appContainer.navManager.habitToOpen = nil
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !vm.allBaseHabits.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        isEditMode = isEditMode == .active ? .inactive : .active
                    }
                } label: {
                    Image(systemName: isEditMode == .active ? "checkmark" : "line.3.horizontal")
                        .foregroundStyle(Color.primary)
                }
            }
        }

        if !Calendar.current.isDateInToday(selectedDate) {
            ToolbarItem(placement: .topBarTrailing) {
                Button { selectedDate = Date() } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundStyle(Color.primary)
                }
            }
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            Button { showingNewHabit = true } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color.primary)
            }
        }
    }

    // MARK: - Habits List

    private var habitsList: some View {
        List {
            habitListContent
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $isEditMode)
        .environment(vm)
        .navigationTitle(vm.navigationTitle(for: selectedDate))
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ViewBuilder
    private var habitListContent: some View {
        Section {
            WeeklyCalendarView(selectedDate: $selectedDate)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        ForEach(vm.activeHabits(for: selectedDate)) { habit in
            HabitCard(habit: habit, date: selectedDate, onEdit: {
                habitToEdit = habit
            })
            .opacity(habit.isSkipped(on: selectedDate) ? 0.4 : 1.0)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: DS.Spacing.xs,
                leading: DS.Spacing.reg,
                bottom: DS.Spacing.xs,
                trailing: DS.Spacing.reg
            ))
            .onTapGesture {
                guard isEditMode != .active else { return }
                selectedHabit = habit
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                swipeActions(for: habit)
            }
        }
        .onMove { source, destination in
            vm.moveHabits(from: source, to: destination, date: selectedDate)
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        ContentUnavailableView(
            label: {
                Label(
                    title: {
                        Text("no_habits")
                            .foregroundStyle(Color.primary.gradient)
                            .padding(.bottom, 40)
                    },
                    icon: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.primary.gradient)
                    }
                )
            },
            actions: {
                Button { showingNewHabit = true } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("create_habit")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.onPrimary)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.vertical, DS.Spacing.sm)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
        )
    }

    // MARK: - Swipe Actions

    @ViewBuilder
    private func swipeActions(for habit: Habit) -> some View {
        let isCompleted = habit.progressForDate(selectedDate) >= habit.goal
        Button { vm.completeHabit(habit, date: selectedDate) } label: {
            Label("", systemImage: isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(isCompleted ? .red : .green)

        let isSkipped = habit.isSkipped(on: selectedDate)
        Button { vm.toggleSkip(for: habit, date: selectedDate) } label: {
            Label("", systemImage: isSkipped ? "arrow.left" : "arrow.right")
        }
        .tint(.gray)
    }
}

