import SwiftUI

struct ChartStatsRow: View {
    let averageLabel: String
    let totalLabel: String
    private static let primaryColor: Color = Color.primary
    private static let secondaryColor: Color = Color.secondary.opacity(0.8)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Average")
                    .font( .subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Self.secondaryColor)
                    .textCase(.uppercase)

                Text(averageLabel)
                    .font( .title2)
                    .foregroundStyle(Self.primaryColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("Total")
                    .font( .subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Self.secondaryColor)
                    .textCase(.uppercase)

                Text(totalLabel)
                    .font( .title2)
                    .foregroundStyle(Self.primaryColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
