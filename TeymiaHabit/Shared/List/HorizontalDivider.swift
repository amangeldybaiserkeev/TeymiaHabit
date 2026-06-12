import SwiftUI

struct HorizontalDivider: View {
    @Environment(\.pixelLength) private var pixelLength

    private let color: Color
    private let leadingPadding: CGFloat

    init(
        color: Color = Color(.separator),
        leadingPadding: CGFloat = Spacing.reg
    ) {
        self.color = color
        self.leadingPadding = leadingPadding
    }

    var body: some View {
        color
            .frame(height: pixelLength)
            .padding(.leading, leadingPadding)
    }
}
