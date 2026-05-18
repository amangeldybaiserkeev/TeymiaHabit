import SwiftUI
import SwiftData

struct NotificationsRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppDependencyContainer.self) private var appContainer

    @State private var isPermissionAlertPresented = false

    var body: some View {
#if targetEnvironment(macCatalyst)
        EmptyView()
        #else
        let manager = appContainer.notificationManager
        Toggle(isOn: Binding(
            get: { manager.notificationsEnabled },
            set: { newValue in
                Task { await handleToggle(to: newValue) }
            }
        )) {
            Label {
                Text("Notifications")
            } icon: {
                RowIcon(symbol: .notifications)
                    .symbolEffect(.wiggle, value: manager.notificationsEnabled)
            }
        }
        .tint(nil)
        .alert("Allow Notifications", isPresented: $isPermissionAlertPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") { openSettings() }
        } message: {
            Text(
                "Enable notifications for habit reminders."
            )
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await manager.refreshPermissionStatus() }
            }
        }
#endif
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

