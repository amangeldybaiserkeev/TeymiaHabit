import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class AppDependencyContainer {
    // MARK: - Properties (Managers & Services)
    let proManager = ProManager()
    let navManager = NavigationManager()
    let notificationManager = NotificationManager()
    let timerService = TimerService()
    let widgetService = WidgetService()
    let habitLiveActivityManager = HabitLiveActivityManager()
    
    private(set) var habitService: HabitService
    private(set) var habitWidgetService: HabitWidgetService
    private(set) var soundManager: SoundManager
    private(set) var iconManager: AppIconManager
    
    // MARK: - ViewModels
    let habitsViewModel: HabitsViewModel
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        let habitServiceInstance = HabitService(widgetService: widgetService)
        let soundManagerInstance = SoundManager(proManager: proManager)
        let iconManagerInstance = AppIconManager(proManager: proManager)
        
        let habitWidgetServiceInstance = HabitWidgetService(
            modelContext: modelContext,
            habitService: habitServiceInstance
        )
        
        let habitsVMInstance = HabitsViewModel(
            modelContext: modelContext,
            habitService: habitServiceInstance,
            notificationManager: notificationManager,
            soundManager: soundManagerInstance,
            widgetService: widgetService,
            timerService: timerService
        )
        
        self.habitService = habitServiceInstance
        self.soundManager = soundManagerInstance
        self.iconManager = iconManagerInstance
        self.habitWidgetService = habitWidgetServiceInstance
        self.habitsViewModel = habitsVMInstance
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        NotificationCenter.default.addObserver(
            forName: .proStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.soundManager.validateSelectedSoundForProStatus()
            }
        }
    }
}
