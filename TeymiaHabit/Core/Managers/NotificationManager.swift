@preconcurrency import UserNotifications
import SwiftData

@Observable @MainActor
final class NotificationManager {
    var permissionStatus: Bool = false

    var notificationsEnabled: Bool {
        didSet {
            store("notificationsEnabled", value: notificationsEnabled)
        }
    }

    private(set) var selectedNotificationSound: NotificationSound {
        didSet {
            store("selectedNotificationSound", value: selectedNotificationSound.rawValue)
        }
    }

    init() {
        let storage = UserDefaults.standard
        let soundRaw = storage.string(forKey: "selectedNotificationSound")
            ?? NotificationSound.system.rawValue

        self.selectedNotificationSound = NotificationSound(rawValue: soundRaw) ?? .system
        self.notificationsEnabled = storage.bool(forKey: "notificationsEnabled")

        Task { await refreshPermissionStatus() }
    }

    // MARK: - Public API

    func sendGoalAchievedNotification(for habit: Habit) async {
        guard notificationsEnabled, await ensureAuthorization() else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎉 \(String(localized: "Goal Achieved!"))"
        content.body = String(localized: "You've completed \(habit.title)")
        content.sound = selectedNotificationSound.notificationSound

        let request = UNNotificationRequest(
            identifier: "goal-\(habit.uuid.uuidString)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func setSelectedNotificationSound(_ sound: NotificationSound, modelContext: ModelContext) async {
        selectedNotificationSound = sound

        guard notificationsEnabled else { return }

        await updateAllNotifications(modelContext: modelContext)
    }

    func scheduleNotifications(for habit: Habit) async -> Bool {
        cancelNotifications(for: habit)

        guard notificationsEnabled,
              await ensureAuthorization(),
              let reminderTimes = habit.reminderTimes,
              !reminderTimes.isEmpty else { return false }

        for (index, time) in reminderTimes.enumerated() {
            await scheduleDailyNotifications(for: habit, at: time, index: index)
        }
        return true
    }

    // MARK: - Private Logic

    private func scheduleDailyNotifications(for habit: Habit, at time: Date, index: Int) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        for weekday in Weekday.allCases where habit.isActive(on: weekday) {
            var dateComp = DateComponents()
            dateComp.hour = components.hour
            dateComp.minute = components.minute
            dateComp.weekday = weekday.rawValue

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: true)
            let content = createNotificationContent(for: habit)

            let request = UNNotificationRequest(
                identifier: "\(habit.uuid.uuidString)-\(weekday.rawValue)-\(index)",
                content: content,
                trigger: trigger
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    private func createNotificationContent(for habit: Habit) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = habit.title
        content.body = ""
        content.sound = selectedNotificationSound.notificationSound
        return content
    }

    // MARK: - Authorization & Housekeeping

    func refreshPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionStatus = (settings.authorizationStatus == .authorized)

        if !permissionStatus && notificationsEnabled {
            notificationsEnabled = false
        }
    }

    func cancelNotifications(for habit: Habit) {
        let habitID = habit.uuid.uuidString
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(habitID) }
                .map { $0.identifier }

            guard !ids.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: ids)
            center.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }

    func updateAllNotifications(modelContext: ModelContext) async {
        let center = UNUserNotificationCenter.current()

        guard notificationsEnabled, await ensureAuthorization() else {
            notificationsEnabled = false
            center.removeAllPendingNotificationRequests()
            return
        }

        let descriptor = FetchDescriptor<Habit>()
        let habits = (try? modelContext.fetch(descriptor)) ?? []

        for habit in habits where !(habit.reminderTimes?.isEmpty ?? true) {
            _ = await scheduleNotifications(for: habit)
        }
    }

    func ensureAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized:
            permissionStatus = true
            return true
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            permissionStatus = granted
            return granted
        default:
            permissionStatus = false
            return false
        }
    }

    private func store(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
