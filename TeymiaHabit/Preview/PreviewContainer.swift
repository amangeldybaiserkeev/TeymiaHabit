import SwiftData

@MainActor
struct PreviewContainer {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(
                for: Habit.self, HabitCompletion.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    static var appContainer: AppDependencyContainer {
        AppDependencyContainer(modelContext: container.mainContext)
    }
}
