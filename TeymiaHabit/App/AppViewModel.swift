import SwiftUI
import SwiftData
import LocalAuthentication

@Observable
final class AppViewModel {
    static let shared = AppViewModel()
    
    let weekdayPrefs = WeekdayPreferences.shared
    let privacyManager = PrivacyManager.shared
    
    // Global UI Overlays State
    var showingGlobalPinView = false
    var globalPinTitle = ""
    var globalPinCode = ""
    var globalPinAction: ((String) -> Void)?
    var globalPinDismiss: (() -> Void)?
    
    var showingBiometricPromo = false
    var globalBiometricType: LABiometryType = .none
    var globalBiometricDisplayName = ""
    var globalBiometricEnable: (() -> Void)?
    var globalBiometricDismiss: (() -> Void)?
    
    private var pendingDeeplink: Habit?
    private var modelContext: ModelContext?

    func setup(with context: ModelContext) {
        self.modelContext = context
    }

    @MainActor func handleScenePhaseChange(_ phase: ScenePhase, context: ModelContext) {
        switch phase {
        case .background:
            try? context.save()
            if privacyManager.isPrivacyEnabled {
                NotificationCenter.default.post(name: .dismissAllSheets, object: nil)
            }
            TimerService.shared.handleAppDidEnterBackground()
            HabitManager.shared.cleanupInactiveViewModels()
            privacyManager.handleAppWillResignActive()
        case .inactive:
            try? context.save()
        case .active:
            WidgetUpdateService.shared.reloadWidgets()
            TimerService.shared.handleAppWillEnterForeground()
            checkPendingHabitFromWidget()
            privacyManager.handleAppDidBecomeActive()
            Task { await HabitLiveActivityManager.shared.restoreActiveActivitiesIfNeeded() }
        @unknown default: break
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "teymiahabit", url.host == "habit",
              let habitId = url.pathComponents.last,
              let habitUUID = UUID(uuidString: habitId),
              let context = modelContext else { return }
        
        Task { @MainActor in
            let descriptor = FetchDescriptor<Habit>(predicate: #Predicate<Habit> { $0.uuid == habitUUID && !$0.isArchived })
            guard let habit = try? context.fetch(descriptor).first else { return }
            if privacyManager.isAppLocked { pendingDeeplink = habit } else { openHabit(habit) }
        }
    }

    func handlePendingDeeplinkIfNeeded() {
        guard let habit = pendingDeeplink else { return }
        NotificationCenter.default.post(name: .dismissAllSheets, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openHabit(habit)
            self.pendingDeeplink = nil
        }
    }

    private func openHabit(_ habit: Habit) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: .openHabitFromDeeplink, object: habit)
        }
    }

    private func checkPendingHabitFromWidget() {
        let suite = "group.com.amanbayserkeev.teymiahabit"
        guard let defaults = UserDefaults(suiteName: suite),
              let habitId = defaults.string(forKey: "pendingHabitIdFromWidget") else { return }
        defaults.removeObject(forKey: "pendingHabitIdFromWidget")
        if let url = URL(string: "teymiahabit://habit/\(habitId)") { handleDeepLink(url) }
    }

    var globalPinEnv: GlobalPinEnvironment {
        GlobalPinEnvironment(
            showPin: { t, a, d in self.globalPinTitle = t; self.globalPinCode = ""; self.globalPinAction = a; self.globalPinDismiss = d; self.showingGlobalPinView = true },
            hidePin: { self.showingGlobalPinView = false },
            showBiometricPromo: { t, n, e, d in self.globalBiometricType = t; self.globalBiometricDisplayName = n; self.globalBiometricEnable = e; self.globalBiometricDismiss = d; self.showingBiometricPromo = true },
            hideBiometricPromo: { self.showingBiometricPromo = false }
        )
    }
}
