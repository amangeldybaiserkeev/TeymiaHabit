import SwiftUI

// MARK: - Entry Point

struct NewHabitView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.dismiss) private var dismiss

    var habit: Habit?

    @State private var viewModel: NewHabitViewModel?

    var body: some View {
        Group {
            if let viewModel {
                NewHabitContentView(viewModel: viewModel, onSave: {
                    viewModel.save()
                    dismiss()
                })
                .interactiveDismissDisabled(viewModel.hasChanges)
            }
        }
        .task {
            guard viewModel == nil else { return }
            viewModel = NewHabitViewModel(
                habitService: appContainer.habitService,
                habit: habit
            )
        }
    }
}

// MARK: - Content View

private struct NewHabitContentView: View {
    @Bindable var viewModel: NewHabitViewModel
    let onSave: () -> Void

    @FocusState private var focusField: NewHabitField?

    var body: some View {
        NavigationStack {
            Form {
                mainInfoSection
                goalSection
                scheduleSection
            }
            .navigationTitle(viewModel.habit == nil ? "create_habit" : "edit_habit")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                navigationToolbar
                keyboardToolbar
            }
            .onAppear {
                focusField = .title
            }
        }
    }
}

// MARK: - Toolbar

private extension NewHabitContentView {

    @ToolbarContentBuilder
    var navigationToolbar: some ToolbarContent {
        CloseToolbarButton()
        ConfirmationToolbarButton(
            action: onSave,
            isDisabled: !viewModel.isFormValid
        )
    }

    @ToolbarContentBuilder
    var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button {
                focusField = nil
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
            }
        }
    }
}

// MARK: - Sections

private extension NewHabitContentView {

    var mainInfoSection: some View {
        Section {
            HabitNameRow(title: $viewModel.title, focus: $focusField)
            IconRow(
                selectedIcon: $viewModel.selectedIcon,
                selectedColor: $viewModel.selectedIconColor,
                hexColor: $viewModel.selectedHexColor,
                actualColor: viewModel.actualColor
            )
        }
    }

    var goalSection: some View {
        Section {
            GoalRow(
                selectedType: $viewModel.selectedType,
                config: $viewModel.goalConfig,
                focus: $focusField
            )
        }
    }

    var scheduleSection: some View {
        Section {
            RepeatDaysRow(activeDays: $viewModel.activeDays)
            StartDateRow(startDate: $viewModel.startDate)
            RemindersRow(
                isReminderEnabled: $viewModel.isReminderEnabled,
                reminderTimes: $viewModel.reminderTimes
            )
        }
    }
}
