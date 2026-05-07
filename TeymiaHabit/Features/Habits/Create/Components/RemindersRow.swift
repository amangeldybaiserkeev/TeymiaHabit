import SwiftUI
import UserNotifications

struct RemindersRow: View {
    @Binding var isReminderEnabled: Bool
    @Binding var reminderTimes: [Date]

    @Environment(AppDependencyContainer.self) private var appContainer

    @State private var isNotificationPermissionAlertPresented = false
    @State private var isProcessingToggle = false

    var body: some View {
        Section {
            Toggle(isOn: Binding(
                get: { isReminderEnabled },
                set: { newValue in
                    guard !isProcessingToggle else { return }
                    if newValue {
                        isProcessingToggle = true
                        Task { await handleReminderToggle(newValue) }
                    } else {
                        withAnimation(DS.Animations.easeInOut) {
                            isReminderEnabled = newValue
                        }
                    }
                }
            )) {
                Label {
                    Text("reminders")
                } icon: {
                    RowIcon(iconName: "bell.badge.fill", color: .red)
                        .symbolEffect(.wiggle, value: isReminderEnabled)
                }
            }
            .disabled(isProcessingToggle)

            if isReminderEnabled {
                reminderTimesList
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .alert("alert_notifications_permission", isPresented: $isNotificationPermissionAlertPresented) {
            Button("button_cancel", role: .cancel) { }
            Button("settings") { openSettings() }
        } message: {
            Text("alert_notifications_permission_message")
        }
    }

    // MARK: - Reminder Times List

    private var reminderTimesList: some View {
        Group {
            ForEach(Array(reminderTimes.indices), id: \.self) { index in
                HStack {
                    Text("reminder \(index + 1)")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $reminderTimes[index],
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)

                    Button {
                        withAnimation(DS.Animations.easeInOut) {
                            guard reminderTimes.indices.contains(index) else { return }
                            reminderTimes.remove(at: index)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.gradient)
                    }
                }
            }

            Button {
                withAnimation(DS.Animations.easeInOut) {
                    reminderTimes.append(Date())
                }
            } label: {
                Label("Add Reminder", systemImage: "plus")
                    .fontWeight(.medium)
            }
        }
    }

    // MARK: - Private Helpers

    private func handleReminderToggle(_ newValue: Bool) async {
        let isAuthorized = await appContainer.notificationManager.ensureAuthorization()

        await MainActor.run {
            isProcessingToggle = false
            withAnimation(DS.Animations.easeInOut) {
                if isAuthorized {
                    isReminderEnabled = newValue
                } else {
                    isReminderEnabled = false
                    isNotificationPermissionAlertPresented = true
                }
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

