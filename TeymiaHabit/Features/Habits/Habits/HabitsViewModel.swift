import Foundation
import SwiftData
import SwiftUI

@Observable @MainActor
final class HabitsViewModel {
    private let modelContext: ModelContext
    private let habitService: HabitService
    private let soundManager: SoundManager
    private let timerService: TimerService
    private(set) var widgetService: WidgetService
    private(set) var notificationManager: NotificationManager
    
    var selectedDate: Date = Date()
//    var isEditMode: EditMode = .inactive TODO
    var allBaseHabits: [Habit] = []
    
    func fetchData() {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        do {
            let fetchedHabits = try modelContext.fetch(descriptor)
            fetchedHabits.forEach { habit in
                _ = habit.title
                _ = habit.iconColor
                _ = habit.iconName
            }
            self.allBaseHabits = fetchedHabits
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    init(
        modelContext: ModelContext,
        habitService: HabitService,
        notificationManager: NotificationManager,
        soundManager: SoundManager,
        widgetService: WidgetService,
        timerService: TimerService
    ) {
        self.modelContext = modelContext
        self.habitService = habitService
        self.notificationManager = notificationManager
        self.soundManager = soundManager
        self.widgetService = widgetService
        self.timerService = timerService
    }
    
    // MARK: - Computed Properties
    
    var activeHabitsForDate: [Habit] {
        allBaseHabits.filter { habit in
            habit.isActiveOnDate(selectedDate) && selectedDate >= habit.startDate
        }
    }
    
    var navigationTitle: String {
        if allBaseHabits.isEmpty { return "" }
        if Calendar.current.isDateInToday(selectedDate) { return "today".capitalized }
        if Calendar.current.isDateInYesterday(selectedDate) { return "yesterday".capitalized }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: selectedDate).capitalized
    }
    
    // MARK: - Actions
    
    private func handleResult(_ didComplete: Bool) {
        if didComplete {
            soundManager.playCompletionSound()
        }
    }
    
    func handleRingTap(on habit: Habit) {
        switch habit.type {
        case .count:
            let result = habitService.addProgress(1, to: habit, date: selectedDate, context: modelContext)
            handleResult(result)
            
        case.time:
            let habitId = habit.uuid.uuidString
            if timerService.isTimerRunning(for: habitId) {
                if let finalProgress = timerService.stopTimer(for: habitId) {
                    let result = habitService.updateProgress(to: finalProgress, for: habit, date: selectedDate, context: modelContext)
                    handleResult(result)
                }
            } else {
                let current = habit.progressForDate(selectedDate)
                _ = timerService.startTimer(for: habitId, baseProgress: current)
            }
        }
        saveAndReload()
    }
    
    func completeHabit(_ habit: Habit) {
        _ = habitService.completeHabit(for: habit, date: selectedDate, context: modelContext)
    }
    
    func toggleSkip(for habit: Habit) {
        if habit.isSkipped(on: selectedDate) {
            habitService.unskipDate(selectedDate, for: habit, context: modelContext)
        } else {
            habitService.skipDate(selectedDate, for: habit, context: modelContext)
        }
    }
    
    func archiveHabit(_ habit: Habit) {
        habitService.archive(habit, context: modelContext)
    }
    
    func deleteHabit(_ habit: Habit) {
        habitService.delete(habit, context: modelContext)
        saveAndReload()
    }
    
    private func saveAndReload() {
        try? modelContext.save()
        widgetService.reloadWidgetsAfterDataChange()
    }
    
    // MARK: - Reorder
    
    func moveHabits(from source: IndexSet, to destination: Int) {
        var updatedAllHabits = allBaseHabits.sorted(by: { $0.displayOrder < $1.displayOrder })
        let habitsToMove = source.map { activeHabitsForDate[$0] }
        let targetIndex: Int
        if destination < activeHabitsForDate.count {
            let targetHabit = activeHabitsForDate[destination]
            targetIndex = updatedAllHabits.firstIndex(of: targetHabit) ?? updatedAllHabits.count
        } else {
            if let lastVisible = activeHabitsForDate.last,
               let lastIndexInAll = updatedAllHabits.firstIndex(of: lastVisible) {
                targetIndex = lastIndexInAll + 1
            } else {
                targetIndex = updatedAllHabits.count
            }
        }
        
        let sourceIndices = IndexSet(habitsToMove.compactMap { updatedAllHabits.firstIndex(of: $0) })
        
        updatedAllHabits.move(fromOffsets: sourceIndices, toOffset: targetIndex)
        for (index, habit) in updatedAllHabits.enumerated() {
            habit.displayOrder = index
        }
        saveAndReload()
    }
    
    // MARK: - Timer
    
    func checkCompletionForActiveTimer(_ habit: Habit) {
        guard let liveProgress = timerService.getLiveProgress(for: habit.uuid.uuidString),
              habit.progressForDate(selectedDate) < habit.goal,
              liveProgress >= habit.goal else { return }
        soundManager.playCompletionSound()
    }
}
