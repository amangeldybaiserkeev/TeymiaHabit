import SwiftUI

struct EmptyStateView<IconContent: View>: View {
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    var footerText: String? = nil
    @ViewBuilder let iconContent: IconContent

    init(
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil,
        footerText: String? = nil,
        @ViewBuilder iconContent: () -> IconContent
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
        self.footerText = footerText
        self.iconContent = iconContent()
    }

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()

            iconContent

            titleAndMessage

            if let buttonTitle, let action {
                actionButton(title: buttonTitle, action: action)
            }

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var titleAndMessage: some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(title)
                .font(DS.AppFont.title3).bold()
                .foregroundStyle(DS.Colors.primary)

            Text(message)
                .font(DS.AppFont.subheadline)
                .foregroundStyle(DS.Colors.secondary)
                .lineLimit(3)
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Button(action: action) {
                Text(title)
                    .font(DS.AppFont.headline)
                    .foregroundStyle(DS.Colors.primaryButtonText)
                    .frame(maxWidth: .infinity, minHeight: DS.TouchTarget.minimum)
            }
            .buttonStyle(.glassProminent)
            .tint(DS.Colors.primaryButton)

            if let footerText {
                Text(footerText)
                    .font(DS.AppFont.footnote)
                    .foregroundStyle(DS.Colors.secondary.opacity(0.8))
            }
        }
    }
}
