import SwiftUI
import SwiftData

struct NotificationsRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppDependencyContainer.self) private var appContainer

    @State private var isPermissionAlertPresented = false

    var body: some View {
        let manager = appContainer.notificationManager
        Toggle(isOn: Binding(
            get: { manager.notificationsEnabled },
            set: { newValue in
                Task { await handleToggle(to: newValue) }
            }
        )) {
            Label {
                Text("settings_notifications")
            } icon: {
                RowIcon(iconName: "bell.badge")
                    .symbolEffect(.wiggle, value: manager.notificationsEnabled)
            }
        }
        .tint(nil)
        .alert("alert_notifications_permission", isPresented: $isPermissionAlertPresented) {
            Button("button_cancel", role: .cancel) { }
            Button("button_settings") { openSettings() }
        } message: {
            Text("alert_notifications_permission_message")
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await manager.refreshPermissionStatus() }
            }
        }
    }

    @MainActor
    private func handleToggle(to newValue: Bool) async {
        let manager = appContainer.notificationManager
        if newValue {
            let isAuthorized = await manager.ensureAuthorization()
            if isAuthorized {
                manager.notificationsEnabled = true
                await manager.updateAllNotifications(modelContext: modelContext)
            } else {
                isPermissionAlertPresented = true
            }
        } else {
            manager.notificationsEnabled = false
            await manager.updateAllNotifications(modelContext: modelContext)
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
