import SwiftUI

struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .inset(by: 3)
                    .fill(configuration.isPressed ? Color.secondary.opacity(0.1) : .clear) // TODO: replace hardcode color
            )
            .contentShape(.rect)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.selection, trigger: configuration.isPressed) { _, newValue in
                newValue == true
            }
    }
}
