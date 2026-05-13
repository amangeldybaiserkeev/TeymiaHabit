import Foundation
import SwiftData

@Observable @MainActor
final class AppDependencyContainer {
    var showingPaywall = false

    // MARK: - Managers
    let navManager = NavigationManager()
    let notificationManager = NotificationManager()
    let timerService = TimerService()
    let habitLiveActivityManager = HabitLiveActivityManager()
    let soundManager = SoundManager()
    let iconManager: any AppIconManagerProtocol
    let widgetService = WidgetService()

    // MARK: - Services
    let habitService: any HabitServiceProtocol
    let storeKitService: StoreKitService = StoreKitService()

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.habitService = HabitService(
            modelContext: modelContext,
            widgetService: widgetService,
            notificationManager: notificationManager,
            timerService: timerService
        )
        self.iconManager = AppIconManager()
    }
}
