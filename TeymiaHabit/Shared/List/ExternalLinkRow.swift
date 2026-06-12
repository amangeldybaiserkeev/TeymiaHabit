import SwiftUI

struct ExternalLinkRow<Icon: View>: View {
    let title: LocalizedStringKey
    var subTitle: String? = nil
    let icon: Icon
    let action: () -> Void

    init(
        title: LocalizedStringKey,
        subTitle: String? = nil,
        icon: Icon,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subTitle = subTitle
        self.icon = icon
        self.action = action
    }

    var body: some View {
        ClickableRow(action: action) {
            icon

            Text(title)
                .foregroundStyle(.appPrimary)

            Spacer()

            HStack(spacing: Spacing.xs) {
                if let subTitle {
                    Text(subTitle)
                        .foregroundStyle(.appSecondary)
                }

                Image(systemName: "arrow.up.forward")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.iconSecondary)
            }
        }
        .hasIcon(Icon.self != EmptyView.self)
    }
}
