import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @Environment(NavigationManager.self) private var navManager
    @State private var selectedDate: Date = .now
    
    var body: some View {
        @Bindable var nav = navManager
        
        TabView(selection: $nav.selectedTab) {
            // Habits
            NavigationStack {
                HabitsView(selectedDate: $selectedDate, selectedHabit: $nav.selectedHabit)
            }
            .tabItem { Label(AppTab.habits.title, systemImage: AppTab.habits.symbolImage) }
            .tag(AppTab.habits)
            
            // Tasks
            NavigationStack { TasksView() }
            .tabItem { Label(AppTab.tasks.title, systemImage: AppTab.tasks.symbolImage) }
            .tag(AppTab.tasks)
            
            // Settings
            NavigationStack { SettingsView() }
            .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.symbolImage) }
            .tag(AppTab.settings)
        }
        .preferredColorScheme(themeMode.colorScheme)
        .tint(.appOrange)
        .sheet(item: $nav.selectedHabit) { habit in
            NavigationStack { HabitDetailView(habit: habit, date: selectedDate) }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

enum AppTab: Hashable {
    case habits, tasks, settings
    
    var symbolImage: String {
        switch self {
        case .habits: return "checkmark.circle.dotted"
        case .tasks: return "checklist"
        case .settings: return "gearshape"
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .habits: return "tabview_habits"
        case .tasks: return "tabview_tasks"
        case .settings: return "tabview_settings"
        }
    }
}
