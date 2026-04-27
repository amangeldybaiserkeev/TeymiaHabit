import Testing
import Foundation
import SwiftData
@testable import TeymiaHabit

@MainActor
@Suite("HabitLocalDataSource Tests", .serialized)
struct HabitLocalDataSourceTests {
    
    // MARK: - Setup
    let sut: HabitLocalDataSource
    let modelContext: ModelContext
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Habit.self, HabitCompletion.self,
            configurations: config
        )
        // Используем mainContext напрямую
        modelContext = ModelContext(container)
        sut = HabitLocalDataSource(modelContext: modelContext)
    }
    
    // MARK: - Helper
    func makeHabit(goal: Int = 5) -> Habit {
        Habit(title: "Test", type: .count, goal: goal, iconName: "star")
    }
    
    // MARK: - Insert & Fetch
    
    @Test("Insert habit — fetchHabits returns it")
    func insertHabit_fetchReturnsIt() throws {
        let habit = makeHabit()
        sut.insert(habit)
        sut.save()
        
        let habits = try sut.fetchHabits()
        #expect(habits.count == 1)
        #expect(habits.first?.title == "Test")
    }
    
    @Test("Insert multiple habits — fetchHabits returns all")
    func insertMultipleHabits_fetchReturnsAll() throws {
        sut.insert(makeHabit())
        sut.insert(makeHabit())
        sut.insert(makeHabit())
        sut.save()
        
        let habits = try sut.fetchHabits()
        #expect(habits.count == 3)
    }
    
    // MARK: - Delete
    
    @Test("Delete habit — fetchHabits returns empty")
    func deleteHabit_fetchReturnsEmpty() throws {
        let habit = makeHabit()
        sut.insert(habit)
        sut.save()
        
        sut.delete(habit)
        sut.save()
        
        let habits = try sut.fetchHabits()
        #expect(habits.isEmpty)
    }
    
    // MARK: - Completions
    
    @Test("Insert completion — fetchCompletions returns it")
    func insertCompletion_fetchReturnsIt() {
        let habit = makeHabit()
        sut.insert(habit)
        
        let today = Date.now
        let completion = HabitCompletion(date: today, value: 3, habit: habit)
        sut.insert(completion)
        sut.save()
        
        let completions = sut.fetchCompletions(for: habit, on: today)
        #expect(completions.count == 1)
        #expect(completions.first?.value == 3)
    }
    
    @Test("FetchCompletions — returns only completions for given date")
    func fetchCompletions_returnsOnlyForGivenDate() {
        let habit = makeHabit()
        sut.insert(habit)
        
        let today = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        sut.insert(HabitCompletion(date: today, value: 3, habit: habit))
        sut.insert(HabitCompletion(date: yesterday, value: 5, habit: habit))
        sut.save()
        
        let completions = sut.fetchCompletions(for: habit, on: today)
        #expect(completions.count == 1)
        #expect(completions.first?.value == 3)
    }
    
    @Test("Delete completion — fetchCompletions returns empty")
    func deleteCompletion_fetchReturnsEmpty() {
        let habit = makeHabit()
        sut.insert(habit)
        
        let completion = HabitCompletion(date: .now, value: 3, habit: habit)
        sut.insert(completion)
        sut.save()
        
        sut.delete(completion)
        sut.save()
        
        let completions = sut.fetchCompletions(for: habit, on: .now)
        #expect(completions.isEmpty)
    }
}
