import SwiftUI

struct HabitProgressView: View {
    let vm: HabitDetailViewModel
    let habit: Habit

    private enum Layout {
        static let ringSize: CGFloat = 170
    }

    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            Spacer()

            ProgressIconButton(
                systemName: "minus",
                action: vm.decrementProgress,
                isDisabled: vm.currentProgress <= 0
            )

            Spacer()

            ProgressRing(
                progress: vm.completionPercentage,
                currentValue: "\(vm.currentProgress)",
                isCompleted: vm.isAlreadyCompleted,
                isExceeded: vm.currentProgress > habit.goal,
                habit: habit,
                size: Layout.ringSize
            )

            Spacer()

            ProgressIconButton(
                systemName: "plus",
                action: vm.incrementProgress
            )

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
    }
}

struct ProgressIconButton: View {
    let systemName: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: DS.IconSize.reg, weight: .medium))
                .foregroundStyle(DS.Colors.primary)
                .frame(width: DS.TouchTarget.comfortable, height: DS.TouchTarget.comfortable)
                .background(DS.Colors.secondary.opacity(0.1), in: .circle)
        }
        .buttonStyle(.plain)
        .contentShape(.circle)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
