import SwiftUI

struct StreaksView: View {
    let current: Int
    let best: Int
    let total: Int

    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            StatsCard(value: "\(current)", label: "stats_streak", icon: "flame.fill",
                      colors: [Color(#colorLiteral(red: 0.9252998829, green: 0.5136612058, blue: 0.004019758198, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.3332247436, blue: 9.563131607e-05, alpha: 1))]
            )
            StatsCard(value: "\(best)", label: "stats_best", icon: "star.fill",
                      colors: [Color(#colorLiteral(red: 0.9843806624, green: 0.7138614655, blue: 0.1765515208, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.5449097157, blue: 0.1412756741, alpha: 1))]
            )
            StatsCard(value: "\(total)", label: "stats_total", icon: "checkmark.circle.fill",
                      colors: [Color(#colorLiteral(red: 0.6391584277, green: 0.7763692737, blue: 0.07849041373, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.6040084958, blue: 0.2196114361, alpha: 1))]
            )
        }
        .padding(.vertical, DS.Spacing.xs)
    }

    @ViewBuilder
    private func StatsCard(value: String, label: LocalizedStringResource, icon: String, colors: [Color]) -> some View {
        VStack(spacing: DS.Spacing.xxs) {
            Text(value)
                .font(DS.AppFont.title)
                .fontWeight(.black)
                .imageScale(.small)
                .foregroundStyle(DS.Colors.primary)

            HStack(spacing: DS.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DS.AppFont.caption)

                Text(label)
                    .font(DS.AppFont.footnote)
                    .fontWeight(.semibold)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                ))
        }
        .frame(maxWidth: .infinity)
    }
}
