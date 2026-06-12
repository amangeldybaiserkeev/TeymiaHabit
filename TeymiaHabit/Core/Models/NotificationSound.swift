import SwiftUI
import UserNotifications

enum NotificationSound: String, CaseIterable, Identifiable {
    case `system`
    case bellsEcho, clear, guitar, happy, magicMarimba, nimbus, pulse, quickChime, retroGame

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .system: return "System"
        case .bellsEcho: return "Bells Echo"
        case .clear: return "Clear"
        case .guitar: return "Guitar"
        case .happy: return "Happy"
        case .magicMarimba: return "Magic Marimba"
        case .nimbus: return "Nimbus"
        case .pulse: return "Pulse"
        case .quickChime: return "Quick Chime"
        case .retroGame: return "Retro Game"
        }
    }

    var fileExtension: String { "wav" }
}

extension NotificationSound {
    var notificationSound: UNNotificationSound {
        if self == .system {
            return .default
        }
        return UNNotificationSound(named: UNNotificationSoundName(rawValue + "." + fileExtension))
    }
}

extension NotificationSound: HabitSoundProtocol {
    var isFree: Bool {
        self == .system
    }
}

protocol HabitSoundProtocol: Identifiable {
    var displayName: LocalizedStringKey { get }
    var rawValue: String { get }
    var isFree: Bool { get }
}
