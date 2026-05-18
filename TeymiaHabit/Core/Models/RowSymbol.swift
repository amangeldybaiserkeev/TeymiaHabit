import SwiftUI

enum RowSymbol {
    case archive, appIcon, appearance(ThemeMode), habitGoal, habitIcon, habitName, language,
         notifications, privacy, rate, share, sounds, habitStartDate, terms

    var iconName: String {
        switch self {
        case .archive: return "archivebox"
        case .appIcon: return "checkmark.app"
        case .appearance(let mode): return mode.iconName
        case .habitGoal: return "trophy"
        case .habitIcon: return "app.specular"
        case .habitName: return "pencil"
        case .language: return "globe.americas"
        case .notifications: return "bell.badge"
        case .privacy: return "lock"
        case .rate: return "star"
        case .share: return "square.and.arrow.up"
        case .sounds: return "speaker.wave.2"
        case .habitStartDate: return "calendar"
        case .terms: return "text.document"
        }
    }
}
