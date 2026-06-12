import Foundation
import SwiftData

@MainActor
final class DatabaseContainer {
    static let shared = DatabaseContainer()

    let modelContainer: ModelContainer

    var modelContext: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        let storeURL: URL
        #if DEBUG
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        storeURL = documentsURL.appendingPathComponent("default.store")
        #else
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.amanbayserkeev.teymiahabit") {
            storeURL = groupURL.appendingPathComponent("Library/Application Support/default.store")
            print("📁 RELEASE mode - Database path: \(storeURL.path)")
        } else {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            storeURL = documentsURL.appendingPathComponent("default.store")
            print("📁 Fallback - Database path: \(storeURL.path)")
        }
        #endif

        let schema = Schema([Habit.self, HabitCompletion.self])
        let config = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            print("✅ ModelContainer created successfully")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            try? FileManager.default.removeItem(at: storeURL)
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
            let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
            try? FileManager.default.removeItem(at: shmURL)
            try? FileManager.default.removeItem(at: walURL)

            do {
                self.modelContainer = try ModelContainer(for: schema, configurations: [config])
                print("ModelContainer created after cleanup")
            } catch {
                fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
            }
        }
    }
}
