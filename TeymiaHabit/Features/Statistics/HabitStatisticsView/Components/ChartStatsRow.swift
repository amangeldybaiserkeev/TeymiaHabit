import SwiftUI

struct ChartStatsRow: View {
    let averageLabel: String
    let totalLabel: String
    private static let primaryColor: Color = DS.Colors.primary
    private static let secondaryColor: Color = DS.Colors.secondary.opacity(0.8)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text("Average")
                    .font(DS.AppFont.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Self.secondaryColor)
                    .textCase(.uppercase)

                Text(averageLabel)
                    .font(DS.AppFont.title2)
                    .foregroundStyle(Self.primaryColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(alignment: .trailing, spacing: DS.Spacing.xxs) {
                Text("Total")
                    .font(DS.AppFont.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Self.secondaryColor)
                    .textCase(.uppercase)

                Text(totalLabel)
                    .font(DS.AppFont.title2)
                    .foregroundStyle(Self.primaryColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
