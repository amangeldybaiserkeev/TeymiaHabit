import SwiftUI

struct ClickableRow<Content: View>: View {
    var padding = RowToken.padding
    var spacing = RowToken.spacing
    let action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button(action: action) {
            ListRow(padding: padding, spacing: spacing) {
                content
            }
        }
        .buttonStyle(RowButtonStyle())
    }
}
