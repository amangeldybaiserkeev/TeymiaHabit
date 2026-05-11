import SwiftUI

struct StartDateRow: View {
    @Binding var startDate: Date

    var body: some View {
        HStack {
            Label {
                Text("Start Date")
            } icon: {
                RowIcon(iconName: "calendar.badge")
            }

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

