import SwiftUI

struct ListRow<Content: View>: View {
    var padding = RowToken.padding
    var spacing = RowToken.spacing
    var minHeight = RowToken.minHeight
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .padding(.horizontal, padding)
        .frame(minHeight: minHeight)
    }
}
