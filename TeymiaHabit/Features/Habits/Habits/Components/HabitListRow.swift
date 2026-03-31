import SwiftUI
import SwiftData

struct HabitListRow: View {
    @Environment(TimerService.self) private var timerService
    @Environment(HabitsViewModel.self) private var vm
    
    let habit: Habit
    let date: Date
    
    // MARK: - Computer Properties
    
    private var isTimerActive: Bool {
        guard habit.modelContext != nil,
              habit.type == .time,
              Calendar.current.isDateInToday(date) else { return false }
        
        return timerService.isTimerRunning(for: habit.uuid.uuidString)
    }
    
    private var cardProgress: Int {
        guard habit.modelContext != nil else { return 0 }
        let _ = timerService.updateTrigger
        
        if isTimerActive {
            return timerService.getLiveProgress(for: habit.uuid.uuidString) ?? habit.progressForDate(date)
        }
        
        return habit.progressForDate(date)
    }
    
    private var cardCompletionPercentage: Double {
        guard habit.goal > 0 else { return 0 }
        return Double(cardProgress) / Double(habit.goal)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HabitIconView(iconName: habit.iconName, iconColor: habit.iconColor)
            
            // Title + Progress
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text("\(habit.formatProgress(cardProgress)) / \(habit.formattedGoal)")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
            
            Spacer()
            
            // Interactive Progress Ring
            Button(action: {
                vm.handleRingTap(on: habit)
            }) {
                ProgressRing(
                    progress: cardCompletionPercentage,
                    currentValue: "",
                    isCompleted: cardProgress >= habit.goal,
                    isExceeded: cardProgress > habit.goal,
                    habit: habit,
                    size: 50,
                    isTimerRunning: isTimerActive
                )
            }
            .buttonStyle(.plain)
        }
        .onChange(of: timerService.updateTrigger) { _, _ in
            if isTimerActive {
                vm.checkCompletionForActiveTimer(habit)
            }
        }
    }
}
    
    
    // MARK: - Habit Card
    
    struct HabitCard: View {
        @Environment(HabitsViewModel.self) private var vm
        
        let habit: Habit
        let date: Date
        
        @State private var isEditPresented = false
        @State private var showDeleteAlert = false
        
        private var isSkipped: Bool { habit.isSkipped(on: date) }
        
        var body: some View {
            HabitListRow(habit: habit, date: date)
                .padding(6)
                .contentShape(Rectangle())
                .contextMenu {
                    skipButton
                    editButton
                    archiveButton
                    Divider()
                    deleteButton
                }
                .deleteSingleHabitAlert(
                    isPresented: $showDeleteAlert,
                    habitName: habit.title,
                    onDelete: { vm.deleteHabit(habit) },
                )
        }
        
        // MARK: - Context Menu Buttons
        
        private var skipButton: some View {
            Button { vm.toggleSkip(for: habit) } label: {
                Label(
                    isSkipped ? "unskip" : "skip",
                    systemImage: isSkipped ? "arrow.left" : "arrow.right"
                )
            }
            .tint(.primary)
        }
        
        private var editButton: some View {
            Button { isEditPresented = true } label: {
                Label("button_edit", systemImage: "pencil")
            }
            .tint(.primary)
        }
        
        private var archiveButton: some View {
            Button { vm.archiveHabit(habit) } label: {
                Label("archive", systemImage: "archivebox")
            }
            .tint(.primary)
        }
        
        private var deleteButton: some View {
            Button(role: .destructive) { showDeleteAlert = true } label: {
                Label("button_delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
