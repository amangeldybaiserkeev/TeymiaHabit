import SwiftUI

struct RepeatDaysRow: View {
    @Binding var activeDays: [Bool]
    
    private var orderedWeekdays: [Weekday] {
        Weekday.orderedByUserPreference
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(orderedWeekdays, id: \.self) { weekday in
                let index = weekday.arrayIndex
                let isActive = activeDays[index]
                let dayName = weekday.shortName.capitalized
                
                Button {
                    toggleDay(index)
                } label: {
                    Text(dayName)
                        .font(.system(size: 12, weight: .semibold))
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(isActive ? DS.Colors.onPrimary.gradient : DS.Colors.secondary.gradient)
                        .frame(width: 40, height: 40)
                        .background {
                            if isActive {
                                Circle()
                                    .fill(DS.Colors.primary.gradient)
                            }
                        }
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
