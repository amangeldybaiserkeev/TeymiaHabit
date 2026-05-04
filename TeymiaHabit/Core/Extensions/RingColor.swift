import SwiftUI
import UIKit

extension Color {
    // MARK: - Private Properties
    private static let lightAmount: CGFloat = 0.7
    private static let darkAmount: CGFloat = 0.07

    // MARK: - Public Methods
    func lightened(by amount: CGFloat = Self.lightAmount) -> Color {
        applyAdjustment(factor: amount)
    }

    func darkened(by amount: CGFloat = Self.darkAmount) -> Color {
        applyAdjustment(factor: -amount)
    }

    /// Returns a gradient pair for ring visuals
    var ringGradientPair: (dark: Color, light: Color) {
        (darkened(), lightened())
    }

    // MARK: - Private Methods
    private func applyAdjustment(factor: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.adjustedBrightness(by: factor))
    }
}

extension UIColor {
    func adjustedBrightness(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        return UIColor(
            hue: h,
            saturation: s,
            brightness: max(0, min(1, b + factor)),
            alpha: a
        )
    }
}

