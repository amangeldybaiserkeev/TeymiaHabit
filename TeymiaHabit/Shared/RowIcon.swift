import SwiftUI

struct RowIcon: View {
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Properties
    let iconName: String
    var weight: Font.Weight = .regular
    var color: Color? = nil
    var gradientColors: [Color]? = nil
    var isWhiteBG: Bool = false
    var size: CGFloat = 22

    // MARK: - Private Constants
    private let frameSize: CGFloat = 29
    private let cornerRadius: CGFloat = 8
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Image(systemName: iconName)
            .font(.system(size: size, weight: weight))
            .imageScale(.small)
            .foregroundStyle(iconForeground)
            .frame(width: frameSize, height: frameSize)
            .background(backgroundContent, in: shape)
            .overlay(
                shape
                    .stroke(.gray.opacity(strokeOpacity), lineWidth: 1.1)
            )
            .glassEffect(.clear, in: shape)
    }
}

// MARK: - Computed Styles
private extension RowIcon {

    var accentStyle: AnyShapeStyle {
        if let colors = gradientColors {
            return AnyShapeStyle(baseGradient(colors))
        }
        return AnyShapeStyle((color ?? .gray).gradient)
    }

    var backgroundContent: AnyShapeStyle {
        if isDark {
            return AnyShapeStyle(Color.rowIconDark.gradient)
        }

        if isWhiteBG {
            return AnyShapeStyle(Color.white.gradient)
        }

        return accentStyle
    }

    var iconForeground: AnyShapeStyle {
        if isDark {
            return accentStyle
        }

        if isWhiteBG {
            return accentStyle
        }

        return AnyShapeStyle(Color.white)
    }

    var strokeOpacity: CGFloat {
        if isDark {
            return 0.1
        }

        return isWhiteBG ? 0.3 : 0.1
    }

    func baseGradient(_ colors: [Color]) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}

#Preview {
    List {
        Section {
            RowIcon(iconName: "circle.righthalf.filled", color: .gray)
            RowIcon(
                iconName: "checkmark",
                weight: .semibold,
                color: Color.primary,
                isWhiteBG: true
            )
            RowIcon(iconName: "archivebox.fill", color: .gray)
            RowIcon(iconName: "speaker.wave.3.fill", color: .pink, size: 20)
            RowIcon(iconName: "bell.badge.fill", color: .red)
            RowIcon(iconName: "globe", color: .blue)
        }

        Section {
            RowIcon(iconName: "star.fill", color: .yellowOrange)
            RowIcon(iconName: "square.and.arrow.up.fill", color: .oceanBlue)
            RowIcon(iconName: "lock.fill", size: 24)
            RowIcon(iconName: "doc.text.fill")
        }
    }
}

