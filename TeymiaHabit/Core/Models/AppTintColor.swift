import SwiftUI

enum AppTintColor: Int, CaseIterable {
    case primary
    case blue
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case indigo

    var color: Color {
        switch self {
        case .primary: Color.primary
        case .blue:   .blue
        case .purple: .purple
        case .pink:   .pink
        case .red:    .red
        case .orange: .orange
        case .yellow: .yellow
        case .green:  .green
        case .mint:   .mint
        case .teal:   .teal
        case .indigo: .indigo
        }
    }

    var localizedName: LocalizedStringResource {
        switch self {
        case .primary: "tint_primary"
        case .blue:   "tint_blue"
        case .purple: "tint_purple"
        case .pink:   "tint_pink"
        case .red:    "tint_red"
        case .orange: "tint_orange"
        case .yellow: "tint_yellow"
        case .green:  "tint_green"
        case .mint:   "tint_mint"
        case .teal:   "tint_teal"
        case .indigo: "tint_indigo"
        }
    }
}
