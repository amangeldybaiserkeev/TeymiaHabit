import SwiftUI

enum ThemeMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var localizedName: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: "circle.righthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon"
        }
    }
}

