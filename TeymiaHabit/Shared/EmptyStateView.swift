import SwiftUI

struct EmptyStateView<IconContent: View>: View {
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?
    var footerText: String?
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
        VStack(spacing: Spacing.lg) {
            Spacer()

            iconContent

            titleAndMessage

            if let buttonTitle, let action {
                actionButton(title: buttonTitle, action: action)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var titleAndMessage: some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font( .title3).bold()
                .foregroundStyle(Color.primary)

            Text(message)
                .font( .subheadline)
                .foregroundStyle(Color.secondary)
                .lineLimit(3)
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: Spacing.xs) {
            Button(action: action) {
                Text(title)
                    .font( .headline)
                    .foregroundStyle(.onPrimary)
                    .frame(maxWidth: .infinity, minHeight: TouchTarget.minimum)
            }
            .buttonStyle(.glassProminent)
            .tint(.appPrimary)

            if let footerText {
                Text(footerText)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary.opacity(0.8))
            }
        }
    }
}
