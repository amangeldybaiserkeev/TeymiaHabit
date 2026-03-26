import Foundation

enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case dark = "AppIconDark"
    case minimal = "AppIconMinimal"
    case minimalDark = "AppIconMinimalDark"
    case blue = "AppIconBlue"
    case green = "AppIconGreen"
    case mint = "AppIconMint"
    case orchid = "AppIconOrchid"
    case purple = "AppIconPurple"
    case red = "AppIconRed"
    case yellow = "AppIconYellow"
    
    var id: String { rawValue }
    
    var title: LocalizedStringResource {
        switch self {
        case .main: return "appicon_main"
        case .dark: return "appicon_dark"
        case .minimal: return "appicon_minimal"
        case .minimalDark: return "appicon_minimal_dark"
        case .blue: return "appicon_blue"
        case .green: return "appicon_green"
        case .mint: return "appicon_mint"
        case .orchid: return "appicon_orchid"
        case .purple: return "appicon_purple"
        case .red: return "appicon_red"
        case .yellow: return "appicon_yellow"
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
    
    // Check if icon requires Pro
    var requiresPro: Bool {
        switch self {
        case .main, .dark:
            return false  // Free icons
        case .minimal, .minimalDark, .blue, .green, .mint, .orchid, .purple, .red, .yellow:
            return true   // Pro icons
        }
    }
}
