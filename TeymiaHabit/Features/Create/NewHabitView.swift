import SwiftUI
import SwiftData
import HealthKit

struct NewHabitView: View {
    let habit: Habit?
    let template: HabitTemplate?
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var source: HabitSource = .manual
    @State private var healthKitMetric: HealthKitMetric?
    @State private var title = ""
    @State private var selectedType: HabitType = .count
    @State private var goalCountText = ""
    @State private var goalHours = 0
    @State private var minutes = 0
    @State private var activeDays: [Bool] = Array(repeating: true, count: 7)
    @State private var startDate = Date()
    @State private var isReminderEnabled = false
    @State private var reminderTimes: [Date] = [Date()]
    @State private var selectedIcon = "book.fill"
    @State private var selectedIconColor: HabitIconColor = .primary

    @FocusState private var focusField: NewHabitField?

    init(habit: Habit? = nil, template: HabitTemplate? = nil, onSave: (() -> Void)? = nil) {
        self.habit = habit
        self.template = template
        self.onSave = onSave
    }

    private var effectiveGoal: Int {
        switch selectedType {
        case .count: Int(goalCountText) ?? 1
        case .time:  (goalHours * 3600) + (minutes * 60)
        }
    }

    private var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let hasGoal: Bool = switch selectedType {
        case .count: (Int(goalCountText) ?? 0) > 0
        case .time:  goalHours > 0 || minutes > 0
        }
        return hasTitle && hasGoal
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HabitNameRow(title: $title, focus: $focusField)
                    IconRow(selectedIcon: $selectedIcon, selectedColor: $selectedIconColor)
                }

                Section {
                    GoalRow(
                        selectedType: $selectedType,
                        countText: $goalCountText,
                        hours: $goalHours,
                        minutes: $minutes,
                        focus: $focusField
                    )
                }

                Section {
                    ActiveDaysRow(activeDays: $activeDays)
                    StartDateRow(startDate: $startDate)
                    RemindersRow(isReminderEnabled: $isReminderEnabled, reminderTimes: $reminderTimes)
                }
            }
            .navigationTitle(habit == nil ? "Create Habit" : "Edit Habit")
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .interactiveDismissDisabled()
            .toolbar {
                DismissToolbarButton()

                ConfirmationToolbarButton(isDisabled: !isFormValid) {
                    save()
                    onSave?()
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button { focusField = nil } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .tint(.appPrimary)
                }
            }
            .onAppear {
                setup()
                focusField = .title
                requestHealthKitPermission()
            }
        }
    }

    // MARK: - Private

    private func setup() {
        if let habit {
            title = habit.title
            selectedType = habit.type
            startDate = habit.startDate
            selectedIcon = habit.iconName
            selectedIconColor = habit.iconColor
            activeDays = habit.activeDays
            isReminderEnabled = habit.reminderTimes?.isEmpty == false
            reminderTimes = habit.reminderTimes ?? [Date()]
            source = habit.source
            healthKitMetric = habit.healthKitMetric
            if habit.type == .count {
                goalCountText = String(habit.goal)
            } else {
                goalHours = habit.goal / 3600
                minutes = (habit.goal % 3600) / 60
            }
        } else if let template {
            title = template.name
            selectedType = template.type
            selectedIcon = template.icon
            selectedIconColor = template.color
            source = template.source
            healthKitMetric = template.healthKitMetric
            if template.type == .count {
                goalCountText = String(template.goal)
            } else {
                goalHours = template.goal / 3600
                minutes = (template.goal % 3600) / 60
            }
        }
    }

    private func requestHealthKitPermission() {
        guard source == .healthKit, let metric = healthKitMetric else { return }
        Task {
            let types: Set<HKObjectType> = metric == .steps
                ? [HKQuantityType(.stepCount)]
                : [HKCategoryType(.sleepAnalysis)]
            await healthKitManager.requestAuthorization(for: types)
        }
    }

    private func save() {
        let scheduledReminders = isReminderEnabled ? reminderTimes : nil

        if let existing = habit {
            let config = Habit.Configuration(
                title: title, type: selectedType, goal: effectiveGoal,
                iconName: selectedIcon, iconColor: selectedIconColor,
                activeDays: activeDays, reminderTimes: scheduledReminders,
                startDate: startDate, source: source, healthKitMetric: healthKitMetric
            )
            existing.update(with: config)
            notificationManager.cancelNotifications(for: existing)
            Task {
                try? modelContext.save()
                if scheduledReminders != nil {
                    await notificationManager.scheduleNotifications(for: existing)
                }
            }
        } else {
            let newHabit = Habit(
                title: title, type: selectedType, goal: effectiveGoal,
                iconName: selectedIcon, iconColor: selectedIconColor,
                activeDays: activeDays, reminderTimes: scheduledReminders,
                startDate: startDate, source: source, healthKitMetric: healthKitMetric
            )
            let ctx = modelContext
            let nm = notificationManager
            Task {
                // Wait for dismiss animations to complete before inserting.
                // modelContext.insert() triggers @Query which switches HabitsContentView
                // from empty→list state, removing the zoom transition source and causing freeze.
                try? await Task.sleep(for: .seconds(0.8))
                ctx.insert(newHabit)
                try? ctx.save()
                if scheduledReminders != nil {
                    _ = await nm.scheduleNotifications(for: newHabit)
                }
            }
        }
    }
}
