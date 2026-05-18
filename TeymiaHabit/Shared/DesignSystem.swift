import SwiftUI

enum DS {
    // MARK: - Colors
    enum Colors {
        static let accent = Color.accent
        static let primary = Color.appPrimary
        static let secondary = Color.secondary
        static let tertiary = Color.appTertiary
        static let onPrimary = Color.onPrimary
        static let premiumBlue = Color.premiumBlue
        static let premiumPink = Color.premiumPink

        static let primaryButton = Color.primaryButton
        static let primaryButtonText = Color.primaryButtonText

        static let appBackground = Color.appBackground
        static let groupBackground = Color.groupBackground
        static let rowBackground = Color.rowBackground
    }

    // MARK: - IconSize
    enum IconSize {
        static let xxs: CGFloat = 12
        static let xs: CGFloat = 16
        static let sm: CGFloat = 20
        static let reg: CGFloat = 24
        static let md: CGFloat = 28
        static let lg: CGFloat = 32
        static let xl: CGFloat = 36
        static let xxl: CGFloat = 40
    }

    // MARK: - Touch Target
    enum TouchTarget {
        static let minimum: CGFloat = 40
        static let comfortable: CGFloat = 44
        static let large: CGFloat = 52
    }

    // MARK: - Radius
    enum Radius {
        static let xxs: CGFloat  = 8
        static let xs: CGFloat  = 12
        static let sm: CGFloat  = 16
        static let reg: CGFloat = 20
        static let md: CGFloat  = 24
        static let lg: CGFloat  = 28
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 36
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let reg: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 32
    }

    // MARK: - Animations

    enum Animations {
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let bouncy = Animation.bouncy(duration: 0.5, extraBounce: 0.2)
        static let snappy = Animation.snappy(duration: 0.5)
        static let easeInOut = Animation.easeInOut(duration: 0.4)
        static let smooth = Animation.smooth(duration: 0.6, extraBounce: 0)
    }

    // MARK: - Typography
    enum AppFont {
        private static func appFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
            .system(style, design: .rounded).weight(weight)
        }

        static let largeTitle = appFont(.largeTitle, weight: .bold)
        static let title = appFont(.title, weight: .bold)
        static let title2 = appFont(.title2, weight: .semibold)
        static let title3 = appFont(.title3, weight: .medium)
        static let headline = appFont(.headline, weight: .semibold)
        static let subheadline = appFont(.subheadline, weight: .regular)
        static let bodyMedium = appFont(.body, weight: .medium)
        static let callout = appFont(.callout, weight: .regular)
        static let footnote = appFont(.footnote, weight: .regular)
        static let footnoteMedium = appFont(.footnote, weight: .medium)
        static let caption = appFont(.caption, weight: .regular)
    }

    // MARK: - Shadows
    enum Shadows {
        struct ShadowConfig {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }

        static let small = ShadowConfig(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
        static let medium = ShadowConfig(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let large = ShadowConfig(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func appShadow(_ shadow: DS.Shadows.ShadowConfig) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

