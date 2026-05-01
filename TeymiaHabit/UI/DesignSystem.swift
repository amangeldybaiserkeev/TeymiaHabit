import SwiftUI

enum DS {
    // MARK: - Colors
    enum Colors {
        static let appPrimary = Color.appPrimary
        static let primaryBackground = Color.primaryBackground
        static let appSecondary = Color.appSecondary
        static let secondaryBackground = Color.secondaryBackground
        static let secondaryOpacity = Color.secondary.opacity(0.1)
        static let appTertiary = Color.appTertiary
        static let rowBackground = Color.rowBackground
        static let onPrimary = Color.onPrimary
    }
    
    // MARK: - IconSize
    enum IconSize {
        static let xs: CGFloat = 16
        static let sm: CGFloat = 20
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
    }
    
    // MARK: - Touch Target
    
    enum TouchTarget {
        static let minimum: CGFloat = 44
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }
    
    // MARK: - Radius
    enum Radius {
        static let xs: CGFloat  = 8
        static let sm: CGFloat  = 12
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 40
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Animations
    
    enum Animations {
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let bouncy = Animation.bouncy(duration: 0.5, extraBounce: 0.1)
        static let snappy = Animation.snappy(duration: 0.3)
        static let easeInOut = Animation.easeInOut(duration: 0.35)
    }
    
    // MARK: - Typography
    enum Typography {
        private static func appFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
            .system(style, design: .rounded).weight(weight)
        }
        
        static let largeTitle    = appFont(.largeTitle,    weight: .bold)
        static let title         = appFont(.title,         weight: .bold)
        static let title2        = appFont(.title2,        weight: .semibold)
        static let title3        = appFont(.title3,        weight: .medium)
        static let headline      = appFont(.headline,      weight: .semibold)
        static let subheadline   = appFont(.subheadline,   weight: .regular)
        static let body          = appFont(.body,          weight: .regular)
        static let bodyMedium    = appFont(.body,          weight: .medium)
        static let footnote      = appFont(.footnote,      weight: .regular)
        static let footnoteMedium = appFont(.footnote,     weight: .medium)
        static let caption       = appFont(.caption,       weight: .regular)
    }
    
    // MARK: - Shadows
    enum Shadows {
        struct ShadowConfig {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
        
        static let small  = ShadowConfig(color: .black.opacity(0.1), radius: 4,  x: 0, y: 2)
        static let medium = ShadowConfig(color: .black.opacity(0.15), radius: 8,  x: 0, y: 4)
        static let large  = ShadowConfig(color: .black.opacity(0.2),  radius: 16, x: 0, y: 8)
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
