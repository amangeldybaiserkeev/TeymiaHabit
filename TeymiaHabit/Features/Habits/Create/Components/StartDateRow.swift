import SwiftUI

struct StartDateRow: View {
    @Binding var startDate: Date

    var body: some View {
        HStack {
            Label(
                title: { Text("start_date") },
                icon: { RowIcon(iconName: "calendar.badge") }
            )

            Spacer()

            DatePicker(
                "",
                selection: $startDate,
                in: HistoryLimits.datePickerRange,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
    }
}

