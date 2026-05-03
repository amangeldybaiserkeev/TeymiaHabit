import SwiftUI

struct PremiumGradientColors {
    static var gradient: LinearGradient {
        LinearGradient(
            colors: [DS.Colors.premiumBlue, DS.Colors.premiumPink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
