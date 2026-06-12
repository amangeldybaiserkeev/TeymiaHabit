import SwiftUI

enum Theme: String, CaseIterable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: .none
        case .light: .light
        case .dark: .dark
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: "swirl.circle.righthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon.stars"
        }
    }

    var color: Color {
        switch self {
        case .system: .appPrimary
        case .light: .appYellow
        case .dark: .indigo
        }
    }
}
