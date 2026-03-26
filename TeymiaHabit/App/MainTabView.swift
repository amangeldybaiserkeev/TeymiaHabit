import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerService.self) private var timerService
    @Query private var allHabits: [Habit]
    @Namespace private var zoomNamespace
    
    @State private var navigationPath = NavigationPath()
    @State private var selectedHabit: Habit? = nil
    @State private var selectedDate: Date = .now
    @State private var selectedTab: AppTab = .habits
    @State private var searchText: String = ""
    
    var body: some View {
        AnimatedTabView(selection: $selectedTab) {
            Tab.init(AppTab.habits.title, systemImage: AppTab.habits.symbolImage, value: .habits) {
                NavigationStack(path: $navigationPath) {
                    HomeView(zoomNamespace: zoomNamespace, selectedDate: $selectedDate, selectedHabit: $selectedHabit)
                        .navigationDestination(item: $selectedHabit) { habit in
                            HabitDetailView(habit: habit, date: selectedDate, zoomNamespace: zoomNamespace)
                                .navigationTransition(.zoom(sourceID: habit.id, in: zoomNamespace))
                        }
                }
            }
            
            Tab.init(AppTab.tasks.title, systemImage: AppTab.tasks.symbolImage, value: .tasks) {
                NavigationStack {
                    TasksView()
                }
            }
            
            Tab.init(AppTab.settings.title, systemImage: AppTab.settings.symbolImage, value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
            
            Tab.init(AppTab.search.title, systemImage: AppTab.search.symbolImage, value: .search, role: .search) {
                NavigationStack {
                    List {
                        
                    }
                    .navigationTitle("Search")
                    .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search..."))
                }
            }
        } effects: { tab in
            switch tab {
            case .habits: [.bounce]
            case .tasks: [.bounce]
            case .settings: [.rotate]
            case .search: [.wiggle]
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .preferredColorScheme(themeMode.colorScheme)
        .tint(.mainApp)
        .onReceive(NotificationCenter.default.publisher(for: .openHabitFromDeeplink)) { notification in
            guard let habit = notification.object as? Habit else { return }
            selectedTab = .habits
            navigationPath.removeLast(navigationPath.count)
            navigationPath.append(habit)
        }
    }
}

enum AppTab: AnimatedTabSelectionProtocol {
    case habits
    case tasks
    case settings
    case search
    
    var symbolImage: String {
        switch self {
        case .habits: return "checkmark.circle.dotted"
        case .tasks: return "checklist"
        case .settings: return "gearshape"
        case .search: return "magnifyingglass"
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .habits: return "tabview_habits"
        case .tasks: return "tabview_tasks"
        case .settings: return "tabview_settings"
        case .search: return "tabview_search"
        }
    }
}
