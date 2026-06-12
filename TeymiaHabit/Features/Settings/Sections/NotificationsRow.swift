import SwiftUI
import SwiftData

struct NotificationsRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(NotificationManager.self) private var notificationManager

    @State private var isPermissionAlertPresented = false

    private let option = SettingsOption.notifications

    var body: some View {
        ActionRow(
            title: option.title,
            icon: SettingsRowIcon(option: option)
                .symbolEffect(.wiggle, value: notificationManager.notificationsEnabled),
            action: {
                let nextValue = !notificationManager.notificationsEnabled
                triggerToggle(to: nextValue)
            }
        ) {
            Toggle("", isOn: Binding(
                get: { notificationManager.notificationsEnabled },
                set: { newValue in triggerToggle(to: newValue) }
            ))
            .labelsHidden()
            .tint(.toggle)
        }
        .alert("Allow Notifications", isPresented: $isPermissionAlertPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") { openSettings() }
        } message: {
            Text("Enable notifications for habit reminders.")
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await notificationManager.refreshPermissionStatus() }
            }
        }
    }

    private func triggerToggle(to newValue: Bool) {
        Task {
            await handleToggle(to: newValue)
        }
    }

    @MainActor
    private func handleToggle(to newValue: Bool) async {
        let manager = notificationManager
        if newValue {
            let isAuthorized = await manager.ensureAuthorization()
            if isAuthorized {
                withAnimation(.snappy) {
                    manager.notificationsEnabled = true
                }
                await manager.updateAllNotifications(modelContext: modelContext)
            } else {
                isPermissionAlertPresented = true
            }
        } else {
            withAnimation(.snappy) {
                manager.notificationsEnabled = false
            }
            await manager.updateAllNotifications(modelContext: modelContext)
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
