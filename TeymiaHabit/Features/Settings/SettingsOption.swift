import SwiftUI

enum SettingsOption {
    case appearance(Theme)
    case appIcon, language, archive, sounds, notifications, minimalist, rate, share, terms, privacy

    private struct OptionData {
        let title: LocalizedStringKey
        let icon: String
        let color: Color
    }

    private var data: OptionData {
        switch self {
        case .appearance(let theme): return OptionData(title: "Appearance", icon: theme.icon, color: theme.color)
        case .appIcon:       return OptionData(title: "App Icon", icon: "checkmark.app", color: .main)
        case .language:      return OptionData(title: "Language", icon: "globe.americas", color: .blue)
        case .archive:       return OptionData(title: "Archive", icon: "archivebox", color: .gray)
        case .sounds:        return OptionData(title: "Sounds", icon: "speaker.wave.2", color: .pink)
        case .notifications: return OptionData(title: "Notifications", icon: "bell.badge", color: .red)
        case .minimalist:    return OptionData(title: "Minimalist Icons", icon: "app.specular", color: .appPrimary)
        case .rate:          return OptionData(title: "Rate", icon: "star", color: .appYellow)
        case .share:         return OptionData(title: "Share", icon: "square.and.arrow.up", color: .appGreen)
        case .terms:         return OptionData(title: "Terms of Service", icon: "document", color: .gray)
        case .privacy:       return OptionData(title: "Privacy Policy", icon: "lock", color: .gray)
        }
    }

    var title: LocalizedStringKey { data.title }
    var icon: String { data.icon }
    var color: Color { data.color }

    var customSize: CGFloat? {
        if case .terms = self { return 20 }
        return nil
    }
}
