import SwiftUI

struct RowIcon: View {
    let symbol: RowSymbol

    var body: some View {
        Image(systemName: symbol.iconName)
            .font(DS.AppFont.callout)
            .fontWeight(.medium)
            .foregroundStyle(DS.Colors.primary)
    }
}
