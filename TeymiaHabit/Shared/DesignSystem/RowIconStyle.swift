import SwiftUI

extension Image {
    func rowIconStyle(
        isInverted: Bool = false,
        primary: Color = .appPrimary,
        secondary: Color = .main
    ) -> some View {
        self
            .font(.callout)
            .fontWeight(.medium)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                isInverted ? secondary.gradient : primary.gradient,
                isInverted ? primary.gradient : secondary.gradient
            )
    }
}
