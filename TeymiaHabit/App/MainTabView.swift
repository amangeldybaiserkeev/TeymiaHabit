import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @AppStorage("appTintColor") private var appTintColor: String = AppTintColor.primary.rawValue
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDate: Date = .now

    var body: some View {
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
        .tint(AppTintColor(rawValue: appTintColor)?.color ?? .primary)
        .preferredColorScheme(themeMode.colorScheme)
        .tabBarMinimizeBehavior(.onScrollDown)
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
                Text("statistics")
            }
        }

        Tab(AppTab.settings.title, systemImage: AppTab.settings.symbolImage, value: .settings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

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

    var title: LocalizedStringResource {
        switch self {
        case .habits: "tabview_habits"
        case .statistics: "tabview_statistics"
        case .settings: "tabview_settings"
        }
    }
}
