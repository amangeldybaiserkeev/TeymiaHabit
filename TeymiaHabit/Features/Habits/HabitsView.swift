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
    @State private var showingTemplates = false
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

    private var activeHabits: [Habit] {
        allHabits.filter {
            !$0.isArchived && $0.isActiveOnDate(selectedDate) && selectedDate >= $0.startDate
        }
    }

    var body: some View {
        Group {
            if activeHabits.isEmpty {
                HabitsEmptyView(showingTemplates: $showingTemplates, namespace: namespace)
            } else {
                habitsList
            }
        }
        .animation(.spring(duration: 0.4), value: activeHabits.isEmpty)
        .fullScreenCover(isPresented: $showingTemplates) {
            TemplatesView(isPresented: $showingTemplates)
                .navigationTransition(.zoom(sourceID: TransitionID.templates, in: namespace))
        }
        .sheet(item: $habitToEdit) { habit in
            NewHabitView(habit: habit, onSave: { habitToEdit = nil })
                .navigationTransition(.zoom(sourceID: habit.id, in: namespace))
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

                    ForEach(activeHabits) { habit in
                        HabitCard(
                            viewModel: viewModel,
                            habit: habit,
                            date: selectedDate,
                            onEdit: { habitToEdit = habit }
                        )
                        .onTapGesture {
                            selectedHabit = habit
                        }
                        .matchedTransitionSource(id: habit.id, in: namespace)
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
                if allHabits.count < storeKitService.maxHabitsCount {
                    showingTemplates = true
                } else {
                    showingPaywall = true
                }
            } label: {
                Image(systemName: "plus")
                    .matchedTransitionSource(id: TransitionID.templates, in: namespace)
            }
            .tint(.appPrimary)
        }
    }
}

// MARK: - HabitsEmptyView

private struct HabitsEmptyView: View {
    @Binding var showingTemplates: Bool
    let namespace: Namespace.ID

    private let iconSize = IconSize.reg

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            HStack(spacing: Spacing.md) {
                Icon(name: "book.person.fill")
                Icon(name: "massage.fill")
                Icon(name: "person.swimmer.fill")
            }

            VStack(spacing: Spacing.xs) {
                Text("No habits yet")
                    .font(.title3).bold()
                    .foregroundStyle(.appPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.appSecondary)
                    .lineLimit(3)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: Spacing.xs) {
                Button {
                    showingTemplates = true
                } label: {
                    Text("Build new Habits")
                        .font(.headline)
                        .foregroundStyle(.onPrimary)
                        .frame(maxWidth: .infinity, minHeight: TouchTarget.minimum)
                }
                .buttonStyle(.glassProminent)
                .tint(.appPrimary)
                .matchedTransitionSource(id: TransitionID.templates, in: namespace)

                Text("Join millions building better habits")
                    .font(.footnote)
                    .foregroundStyle(.appSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity, alignment: .center)
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
