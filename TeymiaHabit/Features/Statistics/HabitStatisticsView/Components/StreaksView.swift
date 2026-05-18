import SwiftUI

struct StreaksView: View {

    let current: Int
    let best: Int
    let total: Int

    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            StatsCard(value: "\(current)", label: "Streak")
            StatsCard(value: "\(best)", label: "Best")
            StatsCard(value: "\(total)", label: "Total")
        }
    }

    @ViewBuilder
    private func StatsCard(value: String, label: LocalizedStringKey) -> some View {
        VStack(spacing: DS.Spacing.xxs) {
            Text(value)
                .font(DS.AppFont.title2)
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(DS.Colors.primary)

                Text(label)
                    .font(DS.AppFont.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .fixedSize(horizontal: false, vertical: true)
    }
}
