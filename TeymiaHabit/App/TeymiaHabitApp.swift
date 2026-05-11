import SwiftUI
import SwiftData

@main
struct TeymiaHabitApp: App {
    let modelContainer: ModelContainer

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var appContainer: AppDependencyContainer

    init() {
        AppFont.configureAppearance()

        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.amanbayserkeev.teymiahabit"
        ) else {
            fatalError("App Group container not found. Check your entitlements.")
        }

        let storeURL = groupURL.appendingPathComponent("Library/Application Support/default.store")
        let schema   = Schema([Habit.self, HabitCompletion.self])
        let config   = ModelConfiguration(schema: schema, url: storeURL)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            self.modelContainer = container
            _appContainer = State(initialValue: AppDependencyContainer(modelContext: container.mainContext))
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environment(appContainer)
                    .task {
                        await appContainer.storeKitService.loadProducts()
                    }
                    .onAppear {
                        setupLiveActivities()
                    }
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }

    // MARK: - Lifecycle

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            try? modelContainer.mainContext.save()
            appContainer.timerService.handleAppDidEnterBackground()

        case .inactive:
            try? modelContainer.mainContext.save()

        case .active:
            appContainer.timerService.handleAppWillEnterForeground()
            appContainer.widgetService.reloadWidgets()
            checkPendingHabitFromWidget()
            setupLiveActivities()

        @unknown default: break
        }
    }

    // MARK: - Deep Link

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "teymiahabit",
              url.host == "habit",
              let habitId = url.pathComponents.last,
              let habitUUID = UUID(uuidString: habitId)
        else { return }

        Task { @MainActor in
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { $0.uuid == habitUUID && !$0.isArchived }
            )
            if let habit = try? modelContainer.mainContext.fetch(descriptor).first {
                appContainer.navManager.openHabit(habit)
            }
        }
    }

    // MARK: - Widget & Live Activities

    private func checkPendingHabitFromWidget() {
        guard
            let defaults = UserDefaults(suiteName: "group.com.amanbayserkeev.teymiahabit"),
            let habitIdString = defaults.string(forKey: "pendingHabitIdFromWidget")
        else { return }

        defaults.removeObject(forKey: "pendingHabitIdFromWidget")

        if let url = URL(string: "teymiahabit://habit/\(habitIdString)") {
            handleDeepLink(url)
        }
    }

    private func setupLiveActivities() {
        Task {
            await appContainer.habitLiveActivityManager.restoreActiveActivitiesIfNeeded()
        }
    }
}
