import SwiftUI
import SwiftData

struct NewHabitView: View {
    let habit: Habit?
    let template: HabitTemplate?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var viewModel = NewHabitViewModel()
    @FocusState private var focusField: NewHabitField?

    init(habit: Habit? = nil, template: HabitTemplate? = nil) {
        self.habit = habit
        self.template = template
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                ListSection {
                    HabitNameRow(
                        title: $viewModel.title,
                        focus: $focusField
                    )
                    IconRow(
                        selectedIcon: $viewModel.selectedIcon,
                        selectedColor: $viewModel.selectedIconColor
                    )
                }

                ListSection(header: "Goal Settings") {
                    GoalRow(
                        selectedType: $viewModel.selectedType,
                        countText: $viewModel.goalCountText,
                        hours: $viewModel.goalHours,
                        minutes: $viewModel.minutes,
                        focus: $focusField
                    )
                }

                ListSection(header: "Schedule") {
                    ActiveDaysRow(activeDays: $viewModel.activeDays)
                    StartDateRow(startDate: $viewModel.startDate)
                    RemindersRow(
                        isReminderEnabled: $viewModel.isReminderEnabled,
                        reminderTimes: $viewModel.reminderTimes
                    )
                }
            }
            .padding(.top, Spacing.reg)
        }
        .navigationTitle(habit == nil ? "Create Habit" : "Edit Habit")
        .toolbarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ConfirmationToolbarButton(isDisabled: !viewModel.isFormValid) {
                viewModel.save(context: modelContext, existingHabit: habit)
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
