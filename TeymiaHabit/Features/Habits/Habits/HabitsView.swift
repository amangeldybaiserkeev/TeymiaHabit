import SwiftUI
import SwiftData

struct HabitsView: View {
    @Query(sort: \Habit.displayOrder) private var allHabits: [Habit]
    
    @Environment(ProManager.self) private var proManager
    @Environment(HabitsViewModel.self) private var vm
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedDate: Date
    @Binding var selectedHabit: Habit?
    
    @State private var showingNewHabit = false
    @State private var showingPaywall = false
    @State private var habitToEdit: Habit? = nil
    @State private var alertState = AlertState()
    @State private var habitForProgress: Habit? = nil
//    @State private var isEditMode: EditMode = .inactive
    
    var body: some View {
        Group {
            if allHabits.isEmpty {
                emptyView
            } else {
                habitsList
            }
        }
        .onAppear { vm.fetchData() } 
        .onChange(of: allHabits, initial: true) { oldValue, newValue in
            Task { @MainActor in
                vm.allBaseHabits = newValue
            }
        }
        .navigationTitle(vm.navigationTitle)
        .toolbar {
//            if !allBaseHabits.isEmpty {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button(action: {
//                        withAnimation {
//                            isEditMode = isEditMode == .active ? .inactive : .active
//                        }
//                    }) {
//                        Image(systemName: isEditMode == .active ? "checkmark" : "line.3.horizontal")
//                            .foregroundStyle(Color.primary)
//                    }
//                }
//            } TODO
            
            if !Calendar.current.isDateInToday(selectedDate) {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            
            ToolbarSpacer(.flexible, placement: .primaryAction)
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if !proManager.isPro && vm.allBaseHabits.count >= 3 {
                        showingPaywall = true
                    } else {
                        showingNewHabit = true
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .sheet(isPresented: $showingNewHabit) {
            NewHabitView()
        }
        .sheet(item: $habitToEdit) { habit in
            NewHabitView(habit: habit)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .deleteSingleHabitAlert(
            isPresented: $alertState.isDeleteAlertPresented,
            habitName: habitForProgress?.title ?? "",
            onDelete: {
                if let habit = habitForProgress {
                    vm.deleteHabit(habit)
                }
                habitForProgress = nil
            }
        )
    }
    
    private var habitsList: some View {
        List {
            Section {
                WeeklyCalendarView(selectedDate: $selectedDate)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            ForEach(vm.activeHabitsForDate) { habit in
                HabitCard(habit: habit, date: selectedDate)
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .opacity(habit.isSkipped(on: selectedDate) ? 0.4 : 1.0)
                .onTapGesture { selectedHabit = habit }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    swipeActions(for: habit)
                }
            }
            .onMove(perform: vm.moveHabits)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
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
                Button(action: {
                    showingNewHabit = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("create_habit")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryInverse)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(.primary).interactive(), in: .capsule)
            }
        )
    }
    
    @ViewBuilder
    private func swipeActions(for habit: Habit) -> some View {
        
        let isCompleted = habit.progressForDate(selectedDate) >= habit.goal
        Button { vm.completeHabit(habit) } label: {
            Label("", systemImage: isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(isCompleted ? .red : .green)
        
        let isSkipped = habit.isSkipped(on: selectedDate)
        Button { vm.toggleSkip(for: habit) } label: {
            Label("", systemImage: isSkipped ? "arrow.left" : "arrow.right")
        }
        .tint(.gray)
    }
}
