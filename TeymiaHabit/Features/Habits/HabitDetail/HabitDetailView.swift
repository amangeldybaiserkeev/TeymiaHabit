import SwiftUI
import SwiftData
import AVFoundation

struct HabitDetailView: View {
    let habit: Habit
    let date: Date
    
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: HabitDetailViewModel?
    @State private var showingStats = false
    @State private var isEditPresented = false
    
    // MARK: - Init
    init(habit: Habit, date: Date) {
        self.habit = habit
        self.date = date
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if habit.modelContext != nil, let vm = viewModel {
                @Bindable var vm = vm
                
                mainContent(vm: vm)
                    .navigationTitle(habit.title)
                    .navigationSubtitle("Goal: \(habit.formattedGoal)")
                    .toolbar { toolbarContent(vm: vm) }
                    .deleteSingleHabitAlert(
                        isPresented: $vm.alertState.isDeleteAlertPresented,
                        habitName: habit.title,
                        onDelete: deleteHabit
                    )
            } else {
                ProgressView()
                    .onAppear(perform: setupViewModel)
            }
        }
        .id(habit.uuid.uuidString)
        .onDisappear { viewModel?.prepareForDeletion() }
        .onChange(of: date) { _, newDate in
            viewModel?.updateDisplayedDate(newDate)
        }
        .sheet(isPresented: $isEditPresented) {
            NewHabitView(habit: habit)
        }
        .sheet(isPresented: $showingStats) {
            HabitStatisticsView(habit: habit)
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
                completeButtonView(viewModel: vm).disabled(vm.isAlreadyCompleted)
            }
            Spacer()
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(vm: HabitDetailViewModel) -> some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button { showingStats = true } label: {
                Label("Show Statistics", systemImage: "chart.bar.fill")
            }
            menuButton(vm: vm)
        }
    }
    
    // MARK: - Buttons
    @ViewBuilder
    private func menuButton(vm: HabitDetailViewModel) -> some View {
        Menu {
            Button(role: .destructive) {
                vm.alertState.isDeleteAlertPresented = true
            } label: {
                Label("button_delete", systemImage: "trash")
            }
            
            Divider()
            
            Button { vm.toggleSkip() } label: {
                Label(vm.isSkipped ? "unskip" : "skip",
                      systemImage: vm.isSkipped ? "arrow.left" : "arrow.right")
            }
            
            Button { isEditPresented = true } label: {
                Label("button_edit", systemImage: "pencil")
            }
            
            Button { archiveHabit() } label: {
                Label("archive", systemImage: "archivebox")
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
            HStack {
                Text(viewModel.isAlreadyCompleted ? "completed" : "complete")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.primaryInverse)
            .frame(maxWidth: .infinity).frame(height: 52).contentShape(Capsule())
            .background(
                LinearGradient(
                    colors: [
                        habit.iconColor.lightColor,
                        habit.iconColor.darkColor
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .capsule
            )
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: .capsule)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    private func archiveHabit() {
        appContainer.habitService.archive(habit, context: modelContext)
        dismiss()
    }
    
    private func deleteHabit() {
        viewModel?.prepareForDeletion()
        dismiss()
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            appContainer.habitService.delete(habit, context: modelContext)
        }
    }
    
    // MARK: - Helpers
    
    private func setupViewModel() {
        if viewModel == nil {
            viewModel = HabitDetailViewModel(
                habit: habit,
                initialDate: date,
                modelContext: modelContext,
                appContainer: appContainer
            )
            viewModel?.onHabitDeleted = { dismiss() }
        }
    }
}
