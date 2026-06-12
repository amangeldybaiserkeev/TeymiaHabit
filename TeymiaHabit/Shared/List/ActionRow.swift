import SwiftUI

struct ActionRow<Icon: View, Content: View>: View {
    let title: LocalizedStringKey
    let icon: Icon
    let action: () -> Void
    let content: () -> Content

    init(
        title: LocalizedStringKey,
        icon: Icon,
        action: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.content = content
    }

    var body: some View {
        ClickableRow(action: action) {
            icon

            Text(title)
                .foregroundStyle(.appPrimary)

            Spacer()

            content()
        }
        .hasIcon(Icon.self != EmptyView.self)
    }
}
