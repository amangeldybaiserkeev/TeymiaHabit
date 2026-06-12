import SwiftUI

struct AppTabView: View {
    @State private var selectedDate = Date.now
    @State private var selection: AppTab = .habits

    var body: some View {
        AnimatedTabView(selection: $selection) {
            tabContent
        } effects: { tab in
            switch tab {
            case .habits, .statistics: [.bounce]
            case .settings: [.rotate]
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    // MARK: - Tabs Content

    @TabContentBuilder<AppTab>
    private var tabContent: some TabContent<AppTab> {
        ForEach(AppTab.allCases, id: \.self) { tab in
            Tab(tab.title, systemImage: tab.icon, value: tab) {
                tab.makeRootView(selectedDate: $selectedDate)
            }
        }
    }
}

// MARK: - Tabs Configuration

private enum AppTab: CaseIterable, Hashable, AnimatedTabSelectionProtocol {
    case habits, statistics, settings

    var icon: String {
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

    @ViewBuilder
    func makeRootView(selectedDate: Binding<Date>) -> some View {
        switch self {
        case .habits:
            NavigationStack {
                HabitsView(selectedDate: selectedDate)
            }
        case .statistics:
            NavigationStack {
                StatisticsView()
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}
