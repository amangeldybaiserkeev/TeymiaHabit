import SwiftUI

struct WeekdayHeaderView: View {
    var body: some View {
        HStack(spacing: Spacing.reg) {
            ForEach(Weekday.orderedByUserPreference, id: \.self) { weekday in
                Text(String(weekday.shortName.prefix(1)).capitalized)
                    .font( .subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Spacing.reg)
    }
}
