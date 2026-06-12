import SwiftUI

struct HabitIconView: View {
    let icon: String?
    let color: HabitIconColor
    var size: CGFloat = IconSize.sm
    var showBackground: Bool = true

    private let backgroundScale: CGFloat  = 2.0
    private let backgroundOpacity: Double = 0.15
    private let fallbackIcon = "book"

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(color.baseColor.opacity(backgroundOpacity))
            }

            Image(icon ?? fallbackIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: size)
                .foregroundStyle(color.baseColor.gradient)
        }
        .frame(size: size * backgroundScale)
    }
}
