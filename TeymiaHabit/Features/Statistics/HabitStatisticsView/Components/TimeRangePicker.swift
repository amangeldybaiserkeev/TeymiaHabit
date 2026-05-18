import SwiftUI

struct TimeRangePicker: View {
    @Binding var selection: ChartTimeRange

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(ChartTimeRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DS.Spacing.xl)
    }
}
