import SwiftUI

struct StartDateRow: View {
    @Binding var startDate: Date

    var body: some View {
        DatePicker(
            selection: $startDate,
            in: HistoryLimits.datePickerRange,
            displayedComponents: .date
        ) {
            NewHabitRow(item: .startDate)
        }
        .datePickerStyle(.compact)
    }
}
