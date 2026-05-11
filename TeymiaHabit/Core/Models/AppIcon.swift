import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case dark = "AppIconDark"
    case mandarin = "AppIconMandarin"
    case mint = "AppIconMint"
    case raspberry = "AppIconRaspberry"
    case lime = "AppIconLime"
    case bumblebee = "AppIconBumblebee"
    case midnightIndigo = "AppIconMidnightIndigo"
    case lagoon = "AppIconLagoon"

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .main: return "Main"
        case .dark: return "Dark"
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
        case .main, .dark, .mandarin: return true
        default: return false
        }
    }
}
