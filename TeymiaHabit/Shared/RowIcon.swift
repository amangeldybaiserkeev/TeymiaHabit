import SwiftUI

struct RowIcon: View {
    let iconName: String

    var body: some View {
        Image(systemName: iconName)
            .font(DS.AppFont.callout)
            .fontWeight(.medium)
            .foregroundStyle(DS.Colors.primary)
    }
}
