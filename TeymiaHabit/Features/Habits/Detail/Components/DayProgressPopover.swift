import SwiftUI

struct DayProgressPopover: View {
    
    private enum Layout {
        static let popoverWidth: CGFloat = 280
        static let inputFontSize: CGFloat = 34
        static let datePickerHeight: CGFloat = 120
    }
    
    // MARK: - Properties
    let habit: Habit
    let date: Date
    let onAddProgress: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var selectedTime: Date = Calendar.current.date(
        bySettingHour: 0, minute: 0, second: 0, of: Date()
    ) ?? Date()
    
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: DS.Spacing.reg) {
            VStack(spacing: DS.Spacing.xxs) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(DS.AppFont.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: DS.Spacing.xxs) {
                    Text(habit.formattedProgress(for: date))
                    Text("|")
                    Text(habit.formattedGoal)
                }
                .font(DS.AppFont.headline)
            }
            .padding(.top, DS.Spacing.sm)
            
            Divider()
            
            Group {
                if habit.type == .count {
                    TextField("0", text: $inputText)
                        .font(.system(size: Layout.inputFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .padding(.vertical, DS.Spacing.xs)
                } else {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxHeight: Layout.datePickerHeight)
                }
            }
            .padding(.horizontal)
            
            actionButton("button_add") {
                addProgress()
            }
        }
        .frame(width: Layout.popoverWidth)
        .onAppear {
            if habit.type == .count {
                isInputFocused = true
            }
        }
    }
    
    // MARK: - Components
    private func actionButton(_ label: LocalizedStringResource, action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            Text(label)
                .font(DS.AppFont.bodyMedium)
                .foregroundStyle(DS.Colors.onPrimary)
                .frame(maxWidth: .infinity, minHeight: DS.TouchTarget.minimum)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.bottom, DS.Spacing.reg)
    }
    
    // MARK: - Logic
    private func addProgress() {
        if habit.type == .count {
            if let val = Int(inputText), val > 0 {
                onAddProgress(val)
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
