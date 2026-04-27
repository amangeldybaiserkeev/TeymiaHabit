import SwiftUI

enum DS {
    // MARK: - Colors
    enum Colors {
        static let appPrimary = Color.appPrimary
        static let appSecondary = Color.appSecondary
        static let primaryBackground = Color.primaryBackground
        static let secondaryBackground = Color.secondaryBackground
        static let rowBackground = Color.rowBackground
        
        static let iconOpacity: Double = 0.15
    }
    
    // MARK: - Icon
    enum Icon {
        static let s16: CGFloat = 16
        static let s20: CGFloat = 20
        static let s24: CGFloat = 24
        static let s32: CGFloat = 32
        
        static let backgroundMultiplier: CGFloat = 2
    }
    
    // MARK: - Radius
    enum Radius {
        static let s8: CGFloat = 8
        static let s12: CGFloat = 12
        static let s16: CGFloat = 16
        static let s24: CGFloat = 24
        static let s28: CGFloat = 28
        static let s32: CGFloat = 32
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let s4: CGFloat = 4
        static let s6: CGFloat = 6
        static let s8: CGFloat = 8
        static let s12: CGFloat = 12
        static let s16: CGFloat = 16
        static let s20: CGFloat = 20
        static let s24: CGFloat = 24
    }
    
    // MARK: - Typography
    enum Typography {
        static let titleLarge = Font.title.bold()
        static let titleMedium = Font.title2.weight(.semibold)
        static let titleSmall = Font.title3.weight(.medium)
        
        static let bodyMedium = Font.body.weight(.medium)
        static let bodyBold = Font.body.bold()
        
        static let footnote = Font.footnote.weight(.regular)
        static let footnoteMedium = Font.footnote.weight(.medium)
        static let footnoteBold = Font.footnote.bold()
        
        static let caption = Font.caption.weight(.regular)
        static let captionMedium = Font.caption.weight(.medium)
        static let captionBold = Font.caption.bold()
        
        static let rowIcon = Font.callout.weight(.medium)
    }
}
