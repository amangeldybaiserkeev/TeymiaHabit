import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HabitRepository {
    private var modelContext: ModelContext { DatabaseContainer.shared.modelContext }
    private let calendar = Calendar.current

    func create(_ habit: Habit) {
        modelContext.insert(habit)
        save()
    }

    func update() {
        save()
    }

    func delete(_ habit: Habit) {
        modelContext.delete(habit)
        save()
    }

    func fetchAll() throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        return try modelContext.fetch(descriptor)
    }

    func saveProgress(_ value: Int, for habit: Habit, on date: Date) {
        let startOfDay = calendar.startOfDay(for: date)

        habit.completions?
            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            .forEach { modelContext.delete($0) }

        if value > 0 {
            let completion = HabitCompletion(date: startOfDay, value: value, habit: habit)
            modelContext.insert(completion)
        }

        save()
    }

    func fetchProgress(for habit: Habit, on date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        return habit.completions?
            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            .reduce(0) { $0 + $1.value } ?? 0
    }

    func deleteProgress(for habit: Habit, on date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        habit.completions?
            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            .forEach { modelContext.delete($0) }
        save()
    }

    func addSkippedDate(_ date: Date, for habit: Habit) {
        let startOfDay = calendar.startOfDay(for: date)
        guard !habit.skippedDates.contains(where: { calendar.isDate($0, inSameDayAs: startOfDay) }) else { return }
        habit.skippedDates.append(startOfDay)
        save()
    }

    func removeSkippedDate(_ date: Date, for habit: Habit) {
        let startOfDay = calendar.startOfDay(for: date)
        habit.skippedDates.removeAll { calendar.isDate($0, inSameDayAs: startOfDay) }
        save()
    }

    private func save() {
        try? modelContext.save()
    }
}
