import SwiftUI

struct GoalRow: View {
    @Binding var selectedType: HabitType
    @Binding var countText: String
    @Binding var hours: Int
    @Binding var minutes: Int
    var focus: FocusState<NewHabitField?>.Binding

    private enum Constants {
        static let rowHeight: CGFloat = 40
        static let inactiveBlur: CGFloat = 5
        static let inactiveOffset: CGFloat = 10
        static let pickerWidth: CGFloat = 200
        static let maxCount = 999_999
    }

    var body: some View {
        Section {
            typeSelectorRow

            ZStack(alignment: .leading) {
                goalRow(for: .count)
                goalRow(for: .time)
            }
            .frame(minHeight: Constants.rowHeight)
            .animation( Animations.spring, value: selectedType)
        }
    }

    // MARK: - Subviews
    private var typeSelectorRow: some View {
        Label {
            HStack {
                Text("daily_goal")
                Spacer()
                Picker("", selection: $selectedType.animation(.snappy)) {
                    Text("Count").tag(HabitType.count)
                    Text("Time").tag(HabitType.time)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: Constants.pickerWidth)
            }
        } icon: {
            RowIconView(symbol: .habitGoal)
                .symbolEffect(.bounce, value: selectedType)
        }
    }

    @ViewBuilder
    private func goalRow(for type: HabitType) -> some View {
        let isActive = selectedType == type

        Label {
            HStack {
                if type == .count {
                    countField
                    Spacer()
                    countStepper
                } else {
                    Text("Choose time")
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    timePicker
                }
            }
            .frame(height: Constants.rowHeight)
        } icon: {
            Image(systemName: type == .count ? "number" : "clock.arrow.2.circlepath")
                .font(.system(size: IconSize.xs, weight: .medium))
                .foregroundStyle(Color.secondary)
        }
        .opacity(isActive ? 1 : 0)
        .blur(radius: isActive ? 0 : Constants.inactiveBlur)
        .offset(x: isActive ? 0 : (type == .count ? -Constants.inactiveOffset : Constants.inactiveOffset))
        .allowsHitTesting(isActive)
    }

    private var countField: some View {
        TextField("Enter count", text: $countText)
            .keyboardType(.numberPad)
            .focused(focus, equals: .count)
            .foregroundStyle(.primary)
            .onChange(of: countText) { _, newValue in
                let digits = newValue.filter(\.isNumber)
                if let value = Int(digits), value > Constants.maxCount {
                    countText = String(Constants.maxCount)
                } else {
                    countText = digits
                }
            }
    }

    private var countStepper: some View {
        Stepper("", value: Binding(
            get: { Int(countText) ?? 1 },
            set: { countText = String(min(max(1, $0), Constants.maxCount)) }
        ), in: 1...Constants.maxCount)
        .labelsHidden()
    }

    private var timePicker: some View {
        let binding = Binding(
            get: {
                let calendar = Calendar.current
                return calendar.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                hours = components.hour ?? 0
                minutes = components.minute ?? 0
            }
        )

        return DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
    }
}
