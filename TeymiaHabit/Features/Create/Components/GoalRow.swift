import SwiftUI

struct GoalRow: View {
    @Binding var selectedType: HabitType
    @Binding var config: GoalConfiguration
    @FocusState.Binding var focus: NewHabitField?

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
            .animation(DS.Animations.spring, value: selectedType)
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
            RowIcon(symbol: .habitGoal)
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
                        .foregroundStyle(DS.Colors.secondary)
                    Spacer()
                    timePicker
                }
            }
            .frame(height: Constants.rowHeight)
        } icon: {
            Image(systemName: type == .count ? "number" : "clock.arrow.2.circlepath")
                .font(.system(size: DS.IconSize.xs, weight: .medium))
                .foregroundStyle(DS.Colors.secondary)
        }
        .font(DS.AppFont.bodyMedium)
        .opacity(isActive ? 1 : 0)
        .blur(radius: isActive ? 0 : Constants.inactiveBlur)
        .offset(x: isActive ? 0 : (type == .count ? -Constants.inactiveOffset : Constants.inactiveOffset))
        .allowsHitTesting(isActive)
    }

    private var countField: some View {
        TextField("Enter count", text: $config.countText)
            .keyboardType(.numberPad)
            .focused($focus, equals: .count)
            .foregroundStyle(DS.Colors.primary)
            .onChange(of: config.countText) { _, newValue in
                let digits = newValue.filter(\.isNumber)
                if let value = Int(digits), value > Constants.maxCount {
                    config.countText = String(Constants.maxCount)
                } else {
                    config.countText = digits
                }
            }
    }

    private var countStepper: some View {
        Stepper("", value: Binding(
            get: { config.parsedCount ?? 1 },
            set: { config.countText = String(min(max(1, $0), Constants.maxCount)) }
        ), in: 1...Constants.maxCount)
        .labelsHidden()
    }

    private var timePicker: some View {
        DatePicker("", selection: $config.dateRepresentation, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .labelsHidden()
    }
}
