import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @AppStorage("appTintColor") private var appTintColor: Int = AppTintColor.primary.rawValue
    @Environment(AppDependencyContainer.self) private var appContainer
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDate: Date = .now

    var body: some View {
        @Bindable var nav = appContainer.navManager

        AnimatedTabView(selection: $nav.selectedTab) {
            tabContent
        } effects: { tab in
            switch tab {
            case .habits:   [.bounce]
            case .tasks:    [.bounce]
            case .settings: [.rotate]
            }
        }
        .fontDesign(.rounded)
        .tint(AppTintColor(rawValue: appTintColor)?.color ?? DS.Colors.appPrimary)
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

        Tab(AppTab.tasks.title, systemImage: AppTab.tasks.symbolImage, value: .tasks) {
            NavigationStack {
                Text("Tasks")
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
    case tasks
    case settings

    var symbolImage: String {
        switch self {
        case .habits:   "checkmark.circle.dotted"
        case .tasks:    "checklist"
        case .settings: "gearshape"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .habits:   "tabview_habits"
        case .tasks:    "tabview_tasks"
        case .settings: "tabview_settings"
        }
    }
}
