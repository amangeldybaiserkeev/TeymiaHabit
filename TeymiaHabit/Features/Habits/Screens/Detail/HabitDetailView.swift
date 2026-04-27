import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    let date: Date
    let appContainer: AppDependencyContainer
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HabitDetailViewModel
    @State private var showingStats = false
    @State private var isEditPresented = false
    
    init(habit: Habit, date: Date, appContainer: AppDependencyContainer) {
        self.habit = habit
        self.date = date
        self.appContainer = appContainer
        _viewModel = State(wrappedValue: appContainer.habitFactory.makeHabitDetailViewModel(
            habit: habit,
            initialDate: date
        ))
    }
    
    var body: some View {
        @Bindable var vm = viewModel
        mainContent(vm: viewModel)
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .toolbar { toolbarContent(vm: viewModel) }
            .deleteSingleHabitAlert(
                isPresented: $vm.alertState.isDeleteAlertPresented,
                habitName: habit.title,
                onDelete: {
                    viewModel.deleteHabit()
                    dismiss()
                }
            )
            .id(habit.uuid.uuidString)
            .onDisappear { viewModel.prepareForDeletion() }
            .onChange(of: date) { _, newDate in
                viewModel.updateDisplayedDate(newDate)
            }
            .sheet(isPresented: $isEditPresented) {
                NewHabitView(habit: habit)
                    .environment(appContainer)
            }
            .sheet(isPresented: $showingStats) {
                HabitStatisticsView(habit: habit)
            }
            .task {
                viewModel.start()
            }
    }
    
    // MARK: - Content
    @ViewBuilder
    private func mainContent(vm: HabitDetailViewModel) -> some View {
        VStack(spacing: 0) {
            Spacer()
            HabitProgressView(viewModel: vm, habit: habit)
            Spacer()
            VStack(spacing: 30) {
                actionButtonsSection(viewModel: vm)
                completeButtonView(viewModel: vm)
                    .disabled(vm.isAlreadyCompleted)
            }
            Spacer()
        }
        .frame(maxWidth: 500, maxHeight: 700)
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(vm: HabitDetailViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button { showingStats = true } label: {
                Image(systemName: "chart.bar.fill")
            }
            .tint(.primary)
        }
        ToolbarItem(placement: .primaryAction) {
            menuButton(vm: vm)
        }
    }
    
    // MARK: - Buttons
    @ViewBuilder
    private func menuButton(vm: HabitDetailViewModel) -> some View {
        Menu {
            Button { isEditPresented = true } label: {
                Label("button_edit", systemImage: "pencil")
            }
            Button {
                vm.archiveHabit()
                dismiss()
            } label: {
                Label("archive", systemImage: "archivebox")
            }
            Divider()
            Button(role: .destructive) {
                vm.alertState.isDeleteAlertPresented = true
            } label: {
                Label("button_delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .tint(.primary)
    }
    
    private func actionButtonsSection(viewModel: HabitDetailViewModel) -> some View {
        ActionButtonsSection(
            habit: habit,
            date: date,
            isToday: Calendar.current.isDateInToday(date),
            isTimerRunning: viewModel.isTimerRunning,
            onReset: { viewModel.resetProgress() },
            onTimerToggle: { viewModel.toggleTimer() }
        )
    }
    
    private func completeButtonView(viewModel: HabitDetailViewModel) -> some View {
        Button(action: { viewModel.completeHabit() }) {
            Text(viewModel.isAlreadyCompleted ? "completed" : "complete")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity, minHeight: 52)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive().tint(habit.actualColor), in: .capsule)
        .padding(.horizontal, 24)
    }
}
