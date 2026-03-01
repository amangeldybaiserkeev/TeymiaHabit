// File: TeymiaHabit/Views/NewHabit/NewHabitView.swift
import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let habit: Habit?
    let onSaveCompletion: (() -> Void)?
    
    // MARK: - State Properties
    @State var title = ""
    @State var selectedType: HabitType = .count
    @State var countGoal: Int = 1
    @State var hours: Int = 1
    @State var minutes: Int = 0
    @State var scheduledTime: HabitTimeOfDay = .anytime
    @State var priority: HabitPriority = .medium
    
    @State var frequency: HabitFrequency = .daily
    @State var customPeriodStart: Weekday = .monday
    @State var customPeriodEnd: Weekday = .sunday
    
    @State var activeDays: [Bool] = Array(repeating: true, count: 7)
    @State var isReminderEnabled = false
    @State var reminderTimes: [Date] = [Date()]
    @State var startDate = Date()
    @State var selectedIcon: String? = "check"
    @State var selectedIconColor: HabitIconColor = .primary
    @State var showPaywall = false
    @State var showingIconPicker = false
    
    @State var subtasks: [SubtaskDraft] = []
    
    // MARK: - Initialization
    init(habit: Habit? = nil, onSaveCompletion: (() -> Void)? = nil) {
        self.habit = habit
        self.onSaveCompletion = onSaveCompletion
         
        if let habit = habit {
            _title = State(initialValue: habit.title)
            _selectedType = State(initialValue: habit.type)
            
            let loadedGoal = habit.frequencyGoal ?? habit.goal
            _countGoal = State(initialValue: habit.type == .count ? loadedGoal : 1)
            _hours = State(initialValue: habit.type == .time ? loadedGoal / 3600 : 1)
            _minutes = State(initialValue: habit.type == .time ? (loadedGoal % 3600) / 60 : 0)
            
            _scheduledTime = State(initialValue: habit.scheduledTime)
            _priority = State(initialValue: habit.priority)
            _frequency = State(initialValue: habit.frequency)
            _customPeriodStart = State(initialValue: habit.customStartWeekday ?? .monday)
            _customPeriodEnd = State(initialValue: habit.customEndWeekday ?? .sunday)
            _activeDays = State(initialValue: habit.activeDays)
            _isReminderEnabled = State(initialValue: habit.reminderTimes != nil && !habit.reminderTimes!.isEmpty)
            _reminderTimes = State(initialValue: habit.reminderTimes ?? [Date()])
            _startDate = State(initialValue: habit.startDate)
            _selectedIcon = State(initialValue: habit.iconName ?? "check")
            _selectedIconColor = State(initialValue: habit.iconColor)
            
            let sortedSubtasks = habit.subtasks?.sorted(by: { $0.displayOrder < $1.displayOrder }) ?? []
            _subtasks = State(initialValue: sortedSubtasks.map { SubtaskDraft(title: $0.title) })
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            mainFormContent // Wird in der Extension (Datei 3) definiert
                .navigationTitle(habit == nil ? "create_habit".localized : "edit_habit".localized)
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.immediately)
                .sheet(isPresented: $showPaywall) { PaywallView() }
                .sheet(isPresented: $showingIconPicker) {
                    NavigationStack {
                        IconPickerView(selectedIcon: $selectedIcon, selectedColor: $selectedIconColor)
                    }
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
                }
                .toolbar { toolbarContent } // Wird in der Extension (Datei 3) definiert
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
    }
}
