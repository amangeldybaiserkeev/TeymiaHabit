// File: TeymiaHabit/Views/NewHabit/NewHabitView.swift
import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let habit: Habit?
    private let onSaveCompletion: (() -> Void)?
    
    @State private var title = ""
    @State private var selectedType: HabitType = .count
    @State private var countGoal: Int = 1
    @State private var hours: Int = 1
    @State private var minutes: Int = 0
    
    // Feature: Tageszeit
    @State private var scheduledTime: HabitTimeOfDay = .anytime
    // Feature: Priorität
    @State private var priority: HabitPriority = .medium
    
    @State private var activeDays: [Bool] = Array(repeating: true, count: 7)
    @State private var isReminderEnabled = false
    @State private var reminderTimes: [Date] = [Date()]
    @State private var startDate = Date()
    @State private var selectedIcon: String? = "check"
    @State private var selectedIconColor: HabitIconColor = .primary
    @State private var showPaywall = false
    @State private var showingIconPicker = false
    
    // Feature: Unteraufgaben
    @State private var subtasks: [SubtaskDraft] = []
    
    // MARK: - Initialization
     
    init(habit: Habit? = nil, onSaveCompletion: (() -> Void)? = nil) {
        self.habit = habit
        self.onSaveCompletion = onSaveCompletion
         
        if let habit = habit {
            _title = State(initialValue: habit.title)
            _selectedType = State(initialValue: habit.type)
            _countGoal = State(initialValue: habit.type == .count ? habit.goal : 1)
            _hours = State(initialValue: habit.type == .time ? habit.goal / 3600 : 1)
            _minutes = State(initialValue: habit.type == .time ? (habit.goal % 3600) / 60 : 0)
            _scheduledTime = State(initialValue: habit.scheduledTime)
            _priority = State(initialValue: habit.priority)
            _activeDays = State(initialValue: habit.activeDays)
            _isReminderEnabled = State(initialValue: habit.reminderTimes != nil && !habit.reminderTimes!.isEmpty)
            _reminderTimes = State(initialValue: habit.reminderTimes ?? [Date()])
            _startDate = State(initialValue: habit.startDate)
            _selectedIcon = State(initialValue: habit.iconName ?? "check")
            _selectedIconColor = State(initialValue: habit.iconColor)
            
            // Bestehende Subtasks in Entwürfe umwandeln und sortieren
            let sortedSubtasks = habit.subtasks?.sorted(by: { $0.displayOrder < $1.displayOrder }) ?? []
            _subtasks = State(initialValue: sortedSubtasks.map { SubtaskDraft(title: $0.title) })
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasValidTitle = !trimmedTitle.isEmpty
        
        let hasValidGoal = selectedType == .count
            ? countGoal > 0
            : (hours > 0 || minutes > 0)
        
        return hasValidTitle && hasValidGoal
    }
    
    private var effectiveGoal: Int {
        switch selectedType {
        case .count:
            return countGoal
        case .time:
            let totalSeconds = (hours * 3600) + (minutes * 60)
            return min(totalSeconds, 86400)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                HabitIdentitySection(
                    selectedIcon: $selectedIcon,
                    selectedColor: $selectedIconColor,
                    title: $title
                )
                
                Section {
                    ColorPickerSection.forIconPicker(selectedColor: $selectedIconColor)
                }
                .listRowBackground(Color.mainRowBackground)
                .listSectionSpacing(14)

                Section {
                    IconSection(
                        selectedIcon: $selectedIcon,
                        selectedColor: $selectedIconColor,
                        onShowFullPicker: {
                            showingIconPicker = true
                        }
                    )
                }
                .listRowBackground(Color.mainRowBackground)
                
                Section {
                    GoalSection(
                        selectedType: $selectedType,
                        countGoal: $countGoal,
                        hours: $hours,
                        minutes: $minutes
                    )
                    Picker(selection: $scheduledTime) {
                        ForEach(HabitTimeOfDay.allCases) { time in
                            Label(time.localizedName, systemImage: time.iconName)
                                .tag(time)
                        }
                    } label: {
                        Label("scheduled_time".localized, systemImage: "clock.fill")
                    }
                    .pickerStyle(.menu)
                    
                    // Priorität
                    Picker(selection: $priority) {
                        ForEach(HabitPriority.allCases) { p in
                            Label(p.localizedName, systemImage: p.iconName)
                                .tag(p)
                        }
                    } label: {
                        Label("priority".localized, systemImage: "flag.fill")
                    }
                    .pickerStyle(.menu)
                }
                .listRowBackground(Color.mainRowBackground)
                

                // Unteraufgaben
                SubtaskManagementSection(subtasks: $subtasks)
                    .listRowBackground(Color.mainRowBackground)
                
                Section {
                    StartDateSection(startDate: $startDate)
                    ActiveDaysSection(activeDays: $activeDays)
                    ReminderSection(
                        isReminderEnabled: $isReminderEnabled,
                        reminderTimes: $reminderTimes,
                        onShowPaywall: {
                            showPaywall = true
                        }
                    )
                }
                .listRowBackground(Color.mainRowBackground)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.mainGroupBackground)
            .navigationTitle(habit == nil ? "create_habit".localized : "edit_habit".localized)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingIconPicker) {
                NavigationStack {
                    IconPickerView(
                        selectedIcon: $selectedIcon,
                        selectedColor: $selectedIconColor
                    )
                }
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard isFormValid else { return }
                        saveHabit()
                    } label: {
                        Text("button_save".localized)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
    }
    
    // MARK: - Private Methods
    
    private func saveHabit() {
        if selectedType == .count && countGoal > 999999 {
            countGoal = 999999
        }
        
        if selectedType == .time {
            let totalSeconds = (hours * 3600) + (minutes * 60)
            if totalSeconds > 86400 {
                hours = 24
                minutes = 0
            }
        }
        
        let targetHabit: Habit
        
        if let existingHabit = habit {
            existingHabit.update(
                title: title,
                type: selectedType,
                goal: effectiveGoal,
                iconName: selectedIcon,
                iconColor: selectedIconColor,
                scheduledTime: scheduledTime,
                priority: priority,
                activeDays: activeDays,
                reminderTimes: isReminderEnabled ? reminderTimes : nil,
                startDate: Calendar.current.startOfDay(for: startDate)
            )
            targetHabit = existingHabit
        } else {
            let newHabit = Habit(
                title: title,
                type: selectedType,
                goal: effectiveGoal,
                iconName: selectedIcon,
                iconColor: selectedIconColor,
                scheduledTime: scheduledTime,
                priority: priority,
                createdAt: Date(),
                activeDays: activeDays,
                reminderTimes: isReminderEnabled ? reminderTimes : nil,
                startDate: startDate
            )
            modelContext.insert(newHabit)
            targetHabit = newHabit
        }
        
        // Synchronisiere Unteraufgaben
        syncSubtasks(for: targetHabit)
        
        handleNotifications(for: targetHabit)
        WidgetUpdateService.shared.reloadWidgetsAfterDataChange()
        
        if let onSaveCompletion = onSaveCompletion {
            onSaveCompletion()
        } else {
            dismiss()
        }
    }
    
    /// Hilfsmethode zur Synchronisation der Subtasks zwischen UI und DB
    private func syncSubtasks(for habit: Habit) {
        if let existingSubtasks = habit.subtasks {
            for subtask in existingSubtasks {
                modelContext.delete(subtask)
            }
        }
        
        for (index, draft) in subtasks.enumerated() {
            let newSubtask = HabitSubtask(
                title: draft.title,
                displayOrder: index,
                habit: habit
            )
            modelContext.insert(newSubtask)
        }
        
        try? modelContext.save()
    }
    
    private func handleNotifications(for habit: Habit) {
        if isReminderEnabled {
            Task {
                let isAuthorized = await NotificationManager.shared.ensureAuthorization()
                if isAuthorized {
                    await NotificationManager.shared.scheduleNotifications(for: habit)
                } else {
                    isReminderEnabled = false
                }
            }
        } else {
            NotificationManager.shared.cancelNotifications(for: habit)
        }
    }
}
