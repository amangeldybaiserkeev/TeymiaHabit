import SwiftUI
import UIKit

extension Color {
    private enum Constants {
        static let lightAmount: CGFloat = 0.7
        static let darkAmount: CGFloat = 0.07
    }

    func lightened(by amount: CGFloat) -> Color {
        applyAdjustment(factor: amount)
    }
    
    func darkened(by amount: CGFloat) -> Color {
        applyAdjustment(factor: -amount)
    }
    
    private func applyAdjustment(factor: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.adjustedBrightness(by: factor))
    }
    
    var ringGradientPair: (dark: Color, light: Color) {
        (
            self.darkened(by: Constants.darkAmount),
            self.lightened(by: Constants.lightAmount)
        )
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
