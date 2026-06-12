import SwiftUI

struct PremiumGradientColors {
    static var gradient: LinearGradient {
        LinearGradient(
            colors: [.premiumBlue, .premiumPink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
