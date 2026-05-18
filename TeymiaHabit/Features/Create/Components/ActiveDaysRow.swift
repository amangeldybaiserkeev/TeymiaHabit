import SwiftUI

struct ActiveDaysRow: View {
    @Binding var activeDays: [Bool]

    private var orderedWeekdays: [Weekday] {
        Weekday.orderedByUserPreference
    }

    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            ForEach(orderedWeekdays, id: \.self) { weekday in
                let index = weekday.arrayIndex
                let isActive = activeDays[index]
                let dayName = weekday.shortName.capitalized

                Button {
                    toggleDay(index)
                } label: {
                    Text(dayName)
                        .font(.system(size: DS.IconSize.xxs, weight: .semibold))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(isActive ? DS.Colors.onPrimary : DS.Colors.secondary)
                        .frame(size: DS.IconSize.xxl)
                        .background {
                            Circle()
                                .fill(isActive ? DS.Colors.primary : .clear)
                        }
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
            }
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: activeDays)
    }

    private func toggleDay(_ index: Int) {
        let activeCount = activeDays.filter { $0 }.count
        if activeCount == 1 && activeDays[index] { return }
        activeDays[index].toggle()
    }
}

