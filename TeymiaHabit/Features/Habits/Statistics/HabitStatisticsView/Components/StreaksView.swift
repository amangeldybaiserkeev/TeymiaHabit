import SwiftUI

struct StreaksView: View {

    let current: Int
    let best: Int
    let total: Int

    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            StatsCard(value: "\(current)", label: "stats_streak")
            StatsCard(value: "\(best)", label: "stats_best")
            StatsCard(value: "\(total)", label: "stats_total")
        }
    }

    @ViewBuilder
    private func StatsCard(value: String, label: LocalizedStringResource) -> some View {
        VStack(spacing: DS.Spacing.xxs) {
            Text(value)
                .font(DS.AppFont.title)
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
