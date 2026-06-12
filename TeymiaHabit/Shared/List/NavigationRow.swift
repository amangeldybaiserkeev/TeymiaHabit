import SwiftUI

struct NavigationRow<Icon: View, Destination: View>: View {
    let title: LocalizedStringKey
    let icon: Icon
    let destination: Destination

    init(
        title: LocalizedStringKey,
        icon: Icon,
        destination: Destination
    ) {
        self.title = title
        self.icon = icon
        self.destination = destination
    }

    var body: some View {
        NavigationLink(destination: destination) {
            ListRow {
                icon

                Text(title)
                    .foregroundStyle(.appPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.iconSecondary)
            }
        }
        .buttonStyle(RowButtonStyle())
        .hasIcon(Icon.self != EmptyView.self)
    }
}
