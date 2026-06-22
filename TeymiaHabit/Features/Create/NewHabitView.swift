import SwiftUI
import SwiftData

struct NewHabitView: View {
    let habit: Habit?
    let template: HabitTemplate?
    var onSave: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var viewModel = NewHabitViewModel()
    @FocusState private var focusField: NewHabitField?

    init(habit: Habit? = nil, template: HabitTemplate? = nil, onSave: (() -> Void)? = nil) {
        self.habit = habit
        self.template = template
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HabitNameRow(
                        title: $viewModel.title,
                        focus: $focusField
                    )
                    IconRow(
                        selectedIcon: $viewModel.selectedIcon,
                        selectedColor: $viewModel.selectedIconColor
                    )
                }

                Section {
                    GoalRow(
                        selectedType: $viewModel.selectedType,
                        countText: $viewModel.goalCountText,
                        hours: $viewModel.goalHours,
                        minutes: $viewModel.minutes,
                        focus: $focusField
                    )
                }

                Section {
                    ActiveDaysRow(activeDays: $viewModel.activeDays)
                    StartDateRow(startDate: $viewModel.startDate)
                    RemindersRow(
                        isReminderEnabled: $viewModel.isReminderEnabled,
                        reminderTimes: $viewModel.reminderTimes
                    )
                }
            }
            .navigationTitle(habit == nil ? "Create Habit" : "Edit Habit")
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ConfirmationToolbarButton(isDisabled: !viewModel.isFormValid) {
                    viewModel.save(context: modelContext, existingHabit: habit)
                    onSave?()
                    dismiss()
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focusField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .tint(.appPrimary)
                }
            }
            .onAppear {
                viewModel.setup(habit: habit, template: template)
                focusField = .title
                viewModel.requestHealthKitPermission(using: healthKitManager)
            }
            .fullScreenCover(isPresented: $viewModel.showingPaywall) {
                PaywallView()
            }
        }
    }
}
