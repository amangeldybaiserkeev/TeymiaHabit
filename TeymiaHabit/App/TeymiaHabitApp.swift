import SwiftUI
import SwiftData

@main
struct TeymiaHabitApp: App {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.theme) private var theme: Theme = .system

    @State private var notificationManager: NotificationManager
    @State private var timerService: TimerService
    @State private var soundManager = SoundManager()
    @State private var storeKitService = StoreKitService()
    @State private var healthKitManager = HealthKitManager()
    @State private var habitService: HabitService

    init() {
        AppFont.configureAppearance()
        let nm = NotificationManager()
        let ts = TimerService()
        _notificationManager = State(wrappedValue: nm)
        _timerService = State(wrappedValue: ts)
        _habitService = State(wrappedValue: HabitService(notificationManager: nm, timerService: ts))
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .modelContainer(DatabaseContainer.shared.modelContainer)
                .preferredColorScheme(theme.colorScheme)
                .fontDesign(.rounded)
                .tint(.main)
                .environment(habitService)
                .environment(notificationManager)
                .environment(soundManager)
                .environment(timerService)
                .environment(storeKitService)
                .environment(healthKitManager)
                .task { await storeKitService.loadProducts() }
                .onAppear { hasCompletedOnboarding = false } // TODO: remove for production
                .sheet(isPresented: $hasCompletedOnboarding) {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
        }
    }
}
