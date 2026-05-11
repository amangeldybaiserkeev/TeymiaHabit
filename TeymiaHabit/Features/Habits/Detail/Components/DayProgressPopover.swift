import SwiftUI

struct DayProgressPopover: View {

    let habit: Habit
    let date: Date
    let onAddProgress: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var inputText: String = ""
    @State private var selectedTime: Date = Calendar.current.date(
        bySettingHour: 0, minute: 0, second: 0, of: Date()
    ) ?? Date()

    @FocusState private var isInputFocused: Bool

    private enum Layout {
        static let popoverWidth: CGFloat = 280
        static let inputFontSize: CGFloat = 34
        static let datePickerHeight: CGFloat = 120
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: DS.Spacing.reg) {
            VStack(spacing: DS.Spacing.xxs) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(DS.AppFont.subheadline)
                    .foregroundStyle(DS.Colors.secondary)

                HStack(spacing: DS.Spacing.xxs) {
                    Text(habit.formattedProgress(for: date))
                    Text("|")
                    Text(habit.formattedGoal)
                }
                .font(DS.AppFont.headline)
            }

            Divider()
                .padding(.horizontal, DS.Spacing.reg)

            Group {
                if habit.type == .count {
                    TextField("0", text: $inputText)
                        .font(.system(size: Layout.inputFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.7),
                                    .init(color: .clear, location: 0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(alignment: .trailing) {
                            Button {
                                withAnimation(DS.Animations.spring) {
                                    inputText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(DS.Colors.secondary.opacity(0.5))
                                    .font(.system(size: DS.IconSize.sm))
                            }
                            .buttonStyle(.plain)
                            .frame(size: DS.TouchTarget.minimum)
                            .contentShape(.rect)
                            .opacity(inputText.isEmpty ?  0 : 1)
                            .scaleEffect(inputText.isEmpty ? 0.001 : 1)
                            .animation(DS.Animations.spring, value: inputText.isEmpty)
                            .disabled(inputText.isEmpty)
                        }
                } else {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxHeight: Layout.datePickerHeight)
                        .compositingGroup()
                }
            }
            .padding(.vertical, DS.Spacing.sm)

            actionButton("Add") {
                addProgress()
            }
        }
        .padding(DS.Spacing.md)
        .frame(width: Layout.popoverWidth)
        .onAppear {
            if habit.type == .count {
                isInputFocused = true
            }
        }
    }

    // MARK: - Components
    private func actionButton(_ label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            Text(label)
                .font(DS.AppFont.bodyMedium)
                .foregroundStyle(DS.Colors.onPrimary)
                .padding(.vertical, DS.Spacing.xxs)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
    }

    // MARK: - Logic
    private func addProgress() {
        if habit.type == .count {
            if let value = Int(inputText), value > 0 {
                onAddProgress(value)
            }
        } else {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
            let totalSeconds = (comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60
            if totalSeconds > 0 {
                onAddProgress(totalSeconds)
            }
        }
    }
}
