import SwiftUI

struct DayProgressPopover: View {
    let habit: Habit
    let date: Date
    
    @Environment(HabitService.self) private var habitService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var selectedTime: Date = Calendar.current.date(
        bySettingHour: 0, minute: 0, second: 0, of: Date()
    ) ?? Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок
            VStack(spacing: 4) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 6) {
                    Text(habit.formattedProgress(for: date))
                    Text("|")
                    Text(habit.formattedGoal)
                }
                .font(.headline)
            }
            .padding(.top, 12)
            
            Divider()
            
            // Ввод данных
            Group {
                if habit.type == .count {
                    TextField("0", text: $inputText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .numberKeyboard()
                        .padding(.vertical, 8)
                } else {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    #if os(iOS)
                        .datePickerStyle(.wheel)
                    #endif
                        .labelsHidden()
                        .frame(maxHeight: 120)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Кнопки действий
            VStack(spacing: 0) {
                actionButton("button_add") { addProgress() }
                
                Divider()
                
                actionButton("complete") {
                    habitService.completeHabit(for: habit, date: date, context: modelContext)
                }
                
                Divider()
                
                actionButton("button_reset", isDestructive: true) {
                    habitService.resetProgress(for: habit, date: date, context: modelContext)
                }
            }
        }
        .frame(width: 280) // Чуть увеличил ширину для комфорта
    }
    
    // Вспомогательный компонент кнопки, чтобы не дублировать код
    private func actionButton(_ label: LocalizedStringResource, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            Text(label)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isDestructive ? .red : .blue)
    }
    
    private func addProgress() {
        if habit.type == .count {
            if let val = Int(inputText), val > 0 {
                habitService.addProgress(val, to: habit, date: date, context: modelContext)
            }
        } else {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
            let totalSeconds = (comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60
            if totalSeconds > 0 {
                habitService.addProgress(totalSeconds, to: habit, date: date, context: modelContext)
            }
        }
    }
}

extension View {
    func numberKeyboard() -> some View {
        #if os(iOS)
        return self.keyboardType(.numberPad)
        #else
        return self
        #endif
    }
}
