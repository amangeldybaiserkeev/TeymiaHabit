import SwiftUI

extension View {
    func deleteHabitAlert(
        habit: Binding<Habit?>,
        onDelete: @escaping (Habit) -> Void
    ) -> some View {
        alert(
            "alert_delete_habit",
            isPresented: Binding(
                get: { habit.wrappedValue != nil },
                set: { if !$0 { habit.wrappedValue = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                habit.wrappedValue.map(onDelete)
            }
        } message: {
            habit.wrappedValue.map { Text("alert_delete_habit_message \($0.title)") }
        }
    }
}
