import WidgetKit

/// Service for managing Home Screen widget updates
@Observable @MainActor
final class WidgetService {
    private let appGroup = "group.com.amanbayserkeev.teymiahabit"
    
    init() {}
    
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Reload widgets with delay for database synchronization
    func reloadWidgetsAfterDataChange() {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
