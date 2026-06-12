import SwiftUI

struct SettingsRowIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isMinimalistIcons) var isMinimalistIcons

    let option: SettingsOption
    var size: CGFloat = 22

    private static let darkBackgroundColor: Color = .settingsRowIconDark
    private static let frameSize: CGFloat = 29
    private static let cornerRadius: CGFloat = 8

    private var finalSize: CGFloat { option.customSize ?? size }
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Self.cornerRadius)

        Image(systemName: option.icon)
            .symbolVariant(isMinimalistIcons ? .none : .fill)
            .contentTransition(.symbolEffect(.replace))
            .font(isMinimalistIcons ? .callout : .system(size: finalSize))
            .fontWeight(isMinimalistIcons ? .medium : .regular)
            .imageScale(isMinimalistIcons ? .large : .small)
            .foregroundStyle(isMinimalistIcons ? AnyShapeStyle(.minimalistIcons) : iconForeground)
            .frame(size: Self.frameSize)
            .background(
                shape.fill(backgroundContent)
                    .opacity(isMinimalistIcons ? 0 : 1)
            )
            .overlay(
                shape
                    .strokeBorder(
                        strokeGradient,
                        lineWidth: isMinimalistIcons ? 0 : 0.8
                    )
            )
            .animation(.smooth, value: isMinimalistIcons)
    }

    private var backgroundContent: AnyShapeStyle {
        if isDark {
            return AnyShapeStyle(Self.darkBackgroundColor.gradient)
        }
        return AnyShapeStyle(option.color)
    }

    private var iconForeground: AnyShapeStyle {
        isDark ? AnyShapeStyle(option.color) : AnyShapeStyle(.white)
    }

    private var strokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.5),
                .white.opacity(0.1),
                .white.opacity(0.1),
                .white.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
