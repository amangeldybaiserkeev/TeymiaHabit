import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(WidgetService.self) private var widgetService
    
    var habit: Habit? = nil
    
    var body: some View {
        NewHabitContentView(
            habit: habit,
            modelContext: modelContext,
            notificationManager: notificationManager,
            widgetService: widgetService
        )
    }
    
}

struct NewHabitContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewHabitViewModel
    @FocusState private var isHabitNameFocused: Bool

    // MARK: - Init
    init(
        habit: Habit?,
        modelContext: ModelContext,
        notificationManager: NotificationManager,
        widgetService: WidgetService
    ) {
        _viewModel = State(wrappedValue: NewHabitViewModel(
            modelContext: modelContext,
            notificationManager: notificationManager,
            widgetService: widgetService,
            habit: habit
        ))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            @Bindable var vm = viewModel
            habitForm(vm: vm)
                .navigationTitle(vm.habit == nil ? "create_habit" : "edit_habit")
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.immediately)
                .toolbar {
                    CloseToolbarButton(dismiss: {
                        dismiss()
                    })
                    ConfirmationToolbarButton(
                        action: {
                            vm.save()
                            dismiss()
                        },
                        isDisabled: !vm.isFormValid
                    )
                    
                    ToolbarSpacer(.flexible, placement: .keyboard)
                    
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            isHabitNameFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
        }
        .onAppear {
            DispatchQueue.main.async {
                isHabitNameFocused = true
            }
        }
        .interactiveDismissDisabled()
    }
    
    // MARK: - Form
    @ViewBuilder
    private func habitForm(vm: NewHabitViewModel) -> some View {
        @Bindable var vm = vm
        Form {
            Section {
                Label {
                    HStack {
                        TextField("habit_name", text: $vm.title)
                            .fontWeight(.medium)
                            .focused($isHabitNameFocused)
                            .onSubmit {
                                isHabitNameFocused = false
                            }
                        
                        Button(action: {
                                withAnimation(DS.Animations.spring) {
                                    vm.title = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.secondary.opacity(0.5))
                                    .font(.system(size: DS.IconSize.sm))
                            }
                            .buttonStyle(.plain)
                            .opacity(vm.title.isEmpty ? 0 : 1)
                            .scaleEffect(vm.title.isEmpty ? 0.001 : 1)
                            .animation(DS.Animations.spring, value: vm.title.isEmpty)
                            .disabled(vm.title.isEmpty)
                    }
                    .contentShape(.rect)
                } icon: {
                    RowIcon(iconName: "applepencil.and.scribble", color: .gray)
                }
                
                NavigationLink {
                    IconPickerView(
                        selectedIcon: $vm.selectedIcon,
                        selectedColor: $vm.selectedIconColor,
                        hexColor: $vm.selectedHexColor
                    )
                } label: {
                    HStack {
                        Label {
                            Text("icon")
                        } icon: {
                            RowIcon(
                                iconName: "app.specular",
                                gradientColors: [.blue, .purple, .pink]
                            )
                        }
                        
                        Spacer()
                        
                        Image(vm.selectedIcon)
                            .resizable()
                            .frame(size: DS.IconSize.sm)
                            .foregroundStyle(vm.actualColor)
                    }
                }
            }
            
            Section {
                GoalSection(
                    selectedType: $vm.selectedType,
                    countGoal: $vm.countGoal,
                    hours: $vm.hours,
                    minutes: $vm.minutes
                )
            }
            
            Section {
                RepeatDaysView(activeDays: $vm.activeDays)
                StartDateSection(startDate: $vm.startDate)
                ReminderSection(
                    isReminderEnabled: $vm.isReminderEnabled,
                    reminderTimes: $vm.reminderTimes
                )
            }
        }
    }
}

enum NewHabitField {
    case title
    case count
}
