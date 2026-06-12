import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case dark = "AppIcon-Dark"
    case primary = "AppIcon-Primary"
    case primaryDark = "AppIcon-PrimaryDark"
    case mandarin = "AppIcon-Mandarin"
    case mint = "AppIcon-Mint"
    case raspberry = "AppIcon-Raspberry"
    case lime = "AppIcon-Lime"
    case bumblebee = "AppIcon-Bumblebee"
    case midnightIndigo = "AppIcon-MidnightIndigo"
    case lagoon = "AppIcon-Lagoon"

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .main: return "Main"
        case .dark: return "Dark"
        case .primary: return "Primary"
        case .primaryDark: return "PrimaryDark"
        case .mandarin: return "Mandarin"
        case .mint: return "Mint"
        case .raspberry: return "Raspberry"
        case .lime: return "Lime"
        case .bumblebee: return "Bumblebee"
        case .midnightIndigo: return "Midnight Indigo"
        case .lagoon: return "Lagoon"
        }
    }

    // Name for UIApplication.setAlternateIconName
    var name: String? {
        self == .main ? nil : rawValue
    }

    // Preview image name for settings
    var previewImageName: String {
        "Preview-\(rawValue)"
    }
}

extension AppIcon {
    var isFree: Bool {
        switch self {
        case .main, .dark, .primary, .primaryDark: return true
        default: return false
        }
    }
}
