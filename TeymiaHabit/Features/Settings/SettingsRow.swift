import SwiftUI

enum SettingsItem: CaseIterable {
    case appIcon, language, archive, sounds, notifications, rate, share, terms, privacy

    private var fields: (title: LocalizedStringKey, icon: String) {
        switch self {
        case .appIcon:       ("App Icon", "checkmark.app")
        case .language:      ("Language", "globe.americas.fill")
        case .archive:       ("Archive", "archivebox")
        case .sounds:        ("Sounds", "speaker.wave.1")
        case .notifications: ("Notifications", "bell.badge")
        case .rate:          ("Rate", "star.hexagon")
        case .share:         ("Share", "square.and.arrow.up")
        case .terms:         ("Terms of Service", "document.on.document")
        case .privacy:       ("Privacy Policy", "lock.badge.checkmark")
        }
    }

    var title: LocalizedStringKey { fields.title }
    var icon: String { fields.icon }

    var needsInvertedIcon: Bool {
        switch self {
        case .notifications, .appIcon, .rate, .share, .privacy:
            return true
        default:
            return false
        }
    }
}

struct SettingsRow: View {
    let item: SettingsItem

    var body: some View {
        Label {
            Text(item.title)
                .foregroundStyle(.appPrimary)
        } icon: {
            Image(systemName: item.icon)
                .rowIconStyle(isInverted: item.needsInvertedIcon)
        }
    }
}
