import SwiftUI

enum AppBackgroundStyle {
    case main
    case grouped
}

struct AppBackground: ViewModifier {
    let style: AppBackgroundStyle

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(
                style == .grouped
                ? DS.Colors.groupBackground
                : DS.Colors.appBackground
            )
    }
}

extension View {
    func appBackground(_ style: AppBackgroundStyle = .main) -> some View {
        modifier(AppBackground(style: style))
    }

    func rowBackground(_ color: Color = DS.Colors.rowBackground) -> some View {
        self.listRowBackground(color)
    }
}
