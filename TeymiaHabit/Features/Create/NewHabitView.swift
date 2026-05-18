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

    @Environment(AppDependencyContainer.self) private var appContainer
    @FocusState private var focusField: NewHabitField?

    var body: some View {
        @Bindable var vm = vm
        @Bindable var container = appContainer

        NavigationStack {
            List {
                mainInfoSection
                goalSection
                scheduleSection
            }
            .applyAdaptiveWidth()
            .appBackground(.grouped)
            .interactiveDismissDisabled(vm.hasChanges)
            .navigationTitle(vm.habit == nil ? "Create Habit" : "Edit Habit")
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                navigationToolbar
                keyboardToolbar
            }
            .onAppear {
                focusField = .title
            }
            .sheet(isPresented: Bindable(appContainer).showingPaywall) {
                PaywallView(storeKitService: appContainer.storeKitService)
            }
        }
        .presentationSizing(.page)
    }
}

// MARK: - Toolbar

private extension NewHabitContentView {

    @ToolbarContentBuilder
    var navigationToolbar: some ToolbarContent {
        CloseToolbarButton(dismiss: onDismiss)
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
            HabitNameRow(
                title: $vm.title,
                focus: $focusField
            )
            IconRow(
                selectedIcon: $vm.selectedIcon,
                selectedColor: $vm.selectedIconColor
            )
        }
        .rowBackground()
    }

    var goalSection: some View {
        Section {
            GoalRow(
                selectedType: $vm.selectedType,
                config: $vm.goalConfig,
                focus: $focusField
            )
        }
        .rowBackground()
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
        .rowBackground()
    }
}
