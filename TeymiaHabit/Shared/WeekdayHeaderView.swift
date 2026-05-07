import SwiftUI

struct WeekdayHeaderView: View {
    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            ForEach(Weekday.orderedByUserPreference, id: \.self) { weekday in
                Text(String(weekday.shortName.prefix(1)).capitalized)
                    .font(DS.AppFont.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DS.Spacing.reg)
    }
}
