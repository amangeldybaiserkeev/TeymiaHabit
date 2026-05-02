import Foundation
import SwiftData

@Observable @MainActor
final class AppDependencyContainer {

    // MARK: - Managers
    let navManager               = NavigationManager()
    let notificationManager      = NotificationManager()
    let timerService             = TimerService()
    let habitLiveActivityManager = HabitLiveActivityManager()
    let soundManager             = SoundManager()
    let iconManager              = AppIconManager()
    let widgetService            = WidgetService()

    // MARK: - Services
    let habitService: HabitService

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.habitService = HabitService(
            modelContext: modelContext,
            widgetService: widgetService,
            notificationManager: notificationManager
        )
    }
}
