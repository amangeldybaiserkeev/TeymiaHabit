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
        static let refDate = Calendar.current.startOfDay(for: .distantPast)
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
                    Text("count").tag(HabitType.count)
                    Text("time").tag(HabitType.time)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: Constants.pickerWidth)
            }
        } icon: {
            RowIcon(iconName: "trophy.fill", color: .yellowOrange)
                .symbolEffect(.bounce, value: selectedType)
        }
    }

    @ViewBuilder
    private func goalRow(for type: HabitType) -> some View {
        let isActive = selectedType == type

        Label {
            goalRowContent(for: type)
        } icon: {
            goalRowIcon(for: type)
        }
        .font(DS.AppFont.bodyMedium)
        .opacity(isActive ? 1 : 0)
        .blur(radius: isActive ? 0 : Constants.inactiveBlur)
        .offset(x: isActive ? 0 : (type == .count ? -Constants.inactiveOffset : Constants.inactiveOffset))
        .allowsHitTesting(isActive)
    }

    @ViewBuilder
    private func goalRowContent(for type: HabitType) -> some View {
        HStack {
            if type == .count {
                countField
            } else {
                Text("goalsection_choose_time")
                    .foregroundStyle(.secondary.opacity(0.8))
            }

            Spacer()

            if type == .count {
                countStepper
            } else {
                DatePicker("", selection: timeBinding, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
        .frame(height: Constants.rowHeight)
    }

    private func goalRowIcon(for type: HabitType) -> some View {
        Image(systemName: type == .count
              ? "number"
              : "clock.arrow.trianglehead.clockwise.rotate.90.path.dotted")
        .font(.system(size: DS.IconSize.xs, weight: .medium))
        .foregroundStyle(DS.Colors.secondary.opacity(0.5))
    }

    // MARK: - Count Controls

    // Rationale: countText is the Single Source of Truth to avoid String-to-Int sync issues.
    // Stepper and TextField both read/write directly to config.countText.

    private var countField: some View {
        TextField("goalsection_enter_count", text: $config.countText)
            .keyboardType(.numberPad)
            .focused($focus, equals: .count)
            .foregroundStyle(.primary)
            .onChange(of: config.countText) { _, newValue in
                // Strip non-numeric characters and enforce the upper bound
                let digits = newValue.filter(\.isNumber)
                let clamped = Int(digits).map { min($0, 999_999) }
                config.countText = clamped.map(String.init) ?? (digits.isEmpty ? "" : digits)
            }
    }

    private var countStepper: some View {
        // Stepper reads parsedCount (or 1 as fallback) and writes back to countText.
        // This keeps countText as the only source of truth.
        let currentValue = config.parsedCount ?? 1
        return Stepper("", value: Binding(
            get: { currentValue },
            set: { config.countText = String(min(max(1, $0), 999_999)) }
        ), in: 1...999_999)
        .labelsHidden()
    }

    // MARK: - Time Helpers

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: config.hours,
                    minute: config.minutes,
                    second: 0,
                    of: Constants.refDate
                ) ?? Constants.refDate
            },
            set: { newValue in
                config.hours   = Calendar.current.component(.hour, from: newValue)
                config.minutes = Calendar.current.component(.minute, from: newValue)
            }
        )
    }
}
