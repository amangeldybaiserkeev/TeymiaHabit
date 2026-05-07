import SwiftUI

// MARK: - Entry Point

struct NewHabitView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.dismiss) private var dismiss

    var habit: Habit?

    var body: some View {
        NewHabitContentView(
            vm: NewHabitViewModel(
                habitService: appContainer.habitService,
                habit: habit
            ),
            onDismiss: { dismiss() }
        )
    }
}

// MARK: - Content View

private struct NewHabitContentView: View {
    @State var vm: NewHabitViewModel
    let onDismiss: () -> Void

    init(vm: NewHabitViewModel, onDismiss: @escaping () -> Void) {
        _vm = State(wrappedValue: vm)
        self.onDismiss = onDismiss
    }

    @FocusState private var focusField: NewHabitField?

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            Form {
                mainInfoSection
                goalSection
                scheduleSection
            }
            .interactiveDismissDisabled(vm.hasChanges)
            .navigationTitle(vm.habit == nil ? "create_habit" : "edit_habit")
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
            action: {
                vm.save()
                onDismiss()
            },
            isDisabled: !vm.isFormValid
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
            .tint(DS.Colors.primary)
        }
    }
}

// MARK: - Sections

private extension NewHabitContentView {

    var mainInfoSection: some View {
        Section {
            HabitNameRow(title: $vm.title, focus: $focusField)
            IconRow(
                selectedIcon: $vm.selectedIcon,
                selectedColor: $vm.selectedIconColor
            )
        }
    }

    var goalSection: some View {
        Section {
            GoalRow(
                selectedType: $vm.selectedType,
                config: $vm.goalConfig,
                focus: $focusField
            )
        }
    }

    var scheduleSection: some View {
        Section {
            ActiveDaysRow(activeDays: $vm.activeDays)
            StartDateRow(startDate: $vm.startDate)
            RemindersRow(
                isReminderEnabled: $vm.isReminderEnabled,
                reminderTimes: $vm.reminderTimes
            )
        }
    }
}
