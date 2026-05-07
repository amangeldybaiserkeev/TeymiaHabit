import SwiftUI
import SwiftData

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
        HabitsContentView(vm: vm, selectedDate: $selectedDate)
    }
}

// MARK: - Content View

struct HabitsContentView: View {
    let vm: HabitsViewModel

    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    @Environment(AppDependencyContainer.self) private var appContainer

    @Namespace private var habitCardAnimation

    @Binding var selectedDate: Date
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<Habit>()
    @State private var selectedHabit: Habit?
    @State private var showingNewHabit = false
    @State private var habitToEdit: Habit?

    var body: some View {
        Group {
            if allHabits.isEmpty {
                emptyView
            } else {
                habitsList
            }
        }
        .onChange(of: allHabits, initial: true) { _, newValue in
            vm.allBaseHabits = newValue
        }
        .sheet(isPresented: $showingNewHabit) {
            NewHabitView()
        }
        .sheet(item: $habitToEdit) { habit in
            NewHabitView(habit: habit)
        }
        .fullScreenCover(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit, date: selectedDate)
                .navigationTransition(.zoom(sourceID: habit.id, in: habitCardAnimation))
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
                if editMode == .active {
                    Button {
                        withAnimation {
                            editMode = .inactive
                            selection.removeAll()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    Button {
                        withAnimation {
                            editMode = .active
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                    .tint(DS.Colors.primary)
                }
            }
        }

        if !Calendar.current.isDateInToday(selectedDate) {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    selectedDate = Date()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                }
                .tint(DS.Colors.primary)
            }
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingNewHabit = true
            } label: {
                Image(systemName: "plus")
            }
            .tint(DS.Colors.primary)
        }
    }

    // MARK: - Habits List

    private var habitsList: some View {
        List(selection: $selection) {
            habitListContent
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $editMode)
        .environment(vm)
        .navigationTitle(vm.navigationTitle(for: selectedDate))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .safeAreaBar(edge: .bottom) {
            if editMode.isEditing && !selection.isEmpty {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        deleteSelected()
                    } label: {
                        Label {
                            Text("Delete (\(selection.count))")
                        } icon: {
                            Image(systemName: "trash")
                        }
                        .padding(DS.Spacing.xs)
                    }
                    .buttonStyle(.glass)
                    .tint(.red)
                }
                .padding(DS.Spacing.reg)
            }
        }
    }

    @ViewBuilder
    private var habitListContent: some View {
        Section {
            WeeklyCalendarView(selectedDate: $selectedDate, vm: vm)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        ForEach(vm.activeHabits(for: selectedDate)) { habit in
            HabitCard(
                habit: habit,
                date: selectedDate,
                onEdit: { habitToEdit = habit },
                namespace: habitCardAnimation
            )
            .tag(habit)
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
                guard editMode != .active else { return }
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

    private func deleteSelected() {
        for habit in selection {
            appContainer.habitService.delete(habit)
        }
        selection.removeAll()
        editMode = .inactive
    }

    // MARK: - Empty View

    private var emptyView: some View {
        ContentUnavailableView {
            Label {
                Text("no_habits")
                    .padding(.bottom, DS.Spacing.xxl)
            } icon: {
                Image(systemName: "")
            }
            .foregroundStyle(DS.Colors.primary)
        } actions: {
            Button {
                showingNewHabit = true
            } label: {
                Label {
                    Text("create_habit")
                } icon: {
                    Image(systemName: "plus")
                }
                .font(DS.AppFont.headline)
                .foregroundStyle(DS.Colors.onPrimary)
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.vertical, DS.Spacing.sm)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }

    // MARK: - Swipe Actions

    @ViewBuilder
    private func swipeActions(for habit: Habit) -> some View {
        let isCompleted = habit.progressForDate(selectedDate) >= habit.goal

        Button {
            vm.completeHabit(habit, date: selectedDate)
        } label: {
            Label("", systemImage: isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(isCompleted ? .red : .green)

        let isSkipped = habit.isSkipped(on: selectedDate)

        Button {
            vm.toggleSkip(for: habit, date: selectedDate)
        } label: {
            Label("", systemImage: isSkipped ? "arrow.left" : "arrow.right")
        }
        .tint(.gray)
    }
}

