import SwiftUI

struct ChartStatsRow: View {
    let averageLabel: String
    let totalLabel: String
    let selectedDateLabel: String?
    let selectedValueLabel: String?
    let primaryColor: Color = DS.Colors.primary
    let secondaryColor: Color = DS.Colors.secondary.opacity(0.5)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("average")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryColor.gradient)

                Text(averageLabel)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryColor.gradient)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let dateLabel = selectedDateLabel, let valueLabel = selectedValueLabel {
                VStack(alignment: .center, spacing: 2) {
                    Text(dateLabel.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(secondaryColor.gradient)

                    Text(valueLabel)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryColor.gradient)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text("total")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryColor.gradient)

                Text(totalLabel)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryColor.gradient)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
    }
}
