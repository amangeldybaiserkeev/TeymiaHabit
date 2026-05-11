import SwiftUI
import SwiftData

// MARK: - AppTab

enum AppTab: AnimatedTabSelectionProtocol {
    case habits
    case statistics
    case settings

    var symbolImage: String {
        switch self {
        case .habits: "checkmark.circle.dotted"
        case .statistics: "chart.bar"
        case .settings: "gearshape"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .habits: "Habits"
        case .statistics: "Statistics"
        case .settings: "Settings"
        }
    }
}

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDate: Date = .now

    var body: some View {
        @Bindable var appContainer = appContainer
        @Bindable var nav = appContainer.navManager

        AnimatedTabView(selection: $nav.selectedTab) {
            tabContent
        } effects: { tab in
            switch tab {
            case .habits: [.bounce]
            case .statistics: [.bounce]
            case .settings: [.rotate]
            }
        }
        .fontDesign(.rounded)
        .tint(DS.Colors.primary)
        .preferredColorScheme(themeMode.colorScheme)
        .tabBarMinimizeBehavior(.onScrollDown)
        .adaptiveSheet(isPresented: $appContainer.showingPaywall) {
            PaywallView(storeKitService: appContainer.storeKitService)
        }
    }

    @TabContentBuilder<AppTab>
    private var tabContent: some TabContent<AppTab> {
        Tab(AppTab.habits.title, systemImage: AppTab.habits.symbolImage, value: .habits) {
            NavigationStack {
                HabitsView(
                    selectedDate: $selectedDate,
                    appContainer: appContainer,
                    modelContext: modelContext
                )
            }
        }

        Tab(AppTab.statistics.title, systemImage: AppTab.statistics.symbolImage, value: .statistics) {
            NavigationStack {
                StatisticsView()
            }
        }

        Tab(AppTab.settings.title, systemImage: AppTab.settings.symbolImage, value: .settings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}
