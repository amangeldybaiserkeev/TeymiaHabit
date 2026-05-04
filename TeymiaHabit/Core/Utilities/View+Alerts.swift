import SwiftUI

struct AlertState: Equatable {
    var isDeleteAlertPresented: Bool = false
}

private struct DeleteHabitAlertModifier: ViewModifier {
    @Binding var habit: Habit?

    let onDelete: (Habit) -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                "alert_delete_habit",
                isPresented: .constant(habit != nil)
            ) {
                Button("button_cancel", role: .cancel) {
                    habit = nil
                }
                Button("button_delete", role: .destructive) {
                    if let habit = habit {
                        onDelete(habit)
                    }
                    habit = nil
                }
            } message: {
                if let habit = habit {
                    Text("alert_delete_habit_message \(habit.title)")
                }
            }
    }
}

extension View {
    func deleteHabitAlert(
        habit: Binding<Habit?>,
        onDelete: @escaping (Habit) -> Void
    ) -> some View {
        modifier(DeleteHabitAlertModifier(habit: habit, onDelete: onDelete))
    }
}
