import SwiftUI

enum AppTintColor: String, CaseIterable, Identifiable {
    case primary
    case blue
    case brown
    case cyan
    case gray
    case green
    case indigo
    case mint
    case orange
    case pink
    case purple
    case red
    case teal
    case yellow

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .primary: Color.primary
        case .blue:    .blue
        case .brown:   .brown
        case .cyan:    .cyan
        case .gray:    .gray
        case .green:   .green
        case .indigo:  .indigo
        case .mint:    .mint
        case .orange:  .orange
        case .pink:    .pink
        case .purple:  .purple
        case .red:     .red
        case .teal:    .teal
        case .yellow:  .yellow
        }
    }

    var localizedName: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: "tint_\(rawValue)")
    }
}
