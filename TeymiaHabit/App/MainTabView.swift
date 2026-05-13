import SwiftUI
import SwiftData

enum AppTab: CaseIterable, Hashable {
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
        #if os(iOS)
        // iOS: TabView с кастомным TabBar
        iOSMainView
        #else
        // iPad, macOS, visionOS: NavigationSplitView
        universalMainView
        #endif
    }
    
    // MARK: - iOS Version (TabView)
    #if os(iOS)
    @ViewBuilder
    private var iOSMainView: some View {
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
        .sheet(isPresented: $appContainer.showingPaywall) {
            PaywallView(storeKitService: appContainer.storeKitService)
        }
    }
    #endif
    
    // MARK: - Universal Version (NavigationSplitView для iPad/macOS)
    @ViewBuilder
    private var universalMainView: some View {
        @Bindable var appContainer = appContainer
        
        NavigationSplitView {
            // Sidebar
            List(selection: Binding(
                get: { appContainer.navManager.selectedTab },
                set: { appContainer.navManager.selectedTab = $0 }
            )) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Label(tab.title, systemImage: tab.symbolImage)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Teymia Habit")
            .frame(minWidth: 220)
        } detail: {
            // Detail View
            NavigationStack {
                switch appContainer.navManager.selectedTab {
                case .habits:
                    HabitsView(
                        selectedDate: $selectedDate,
                        appContainer: appContainer,
                        modelContext: modelContext
                    )
                case .statistics:
                    StatisticsView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .preferredColorScheme(themeMode.colorScheme)
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $appContainer.showingPaywall) {
            PaywallView(storeKitService: appContainer.storeKitService)
        }
    }
    
    // MARK: - Shared Tab Content
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
