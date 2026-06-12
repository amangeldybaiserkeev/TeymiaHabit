import SwiftUI

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
    static let xxxs: CGFloat = 2
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
