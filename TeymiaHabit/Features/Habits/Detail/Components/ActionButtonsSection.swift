import SwiftUI

struct ActionButtonsSection: View {
    @State private var isShowingPopover = false

    let habit: Habit
    let date: Date
    let isToday: Bool
    let isTimerRunning: Bool

    var onReset: () -> Void
    var onTimerToggle: () -> Void
    var onAddProgress: (Int) -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.lg) {
            if habit.type == .time && isToday {
                resetButton
                playPauseButton
                manualEntryButton
            } else {
                Spacer()
                resetButton
                manualEntryButton
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Buttons

    private var resetButton: some View {
        Button {
            onReset()
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: DS.IconSize.reg, weight: .medium))
                .foregroundStyle(DS.Colors.primary)
                .frame(width: DS.TouchTarget.comfortable, height: DS.TouchTarget.comfortable)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .contentShape(.circle)
    }

    private var playPauseButton: some View {
        Button {
            onTimerToggle()
        } label: {
            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                .font(.system(size: DS.IconSize.xl))
                .contentTransition(.symbolEffect(.replace, options: .speed(1.3)))
                .foregroundStyle(DS.Colors.primary)
                .frame(width: DS.TouchTarget.comfortable, height: DS.TouchTarget.comfortable)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .contentShape(.circle)
    }

    private var manualEntryButton: some View {
        PopoverView {
            Image(systemName: "plus.arrow.trianglehead.clockwise")
                .font(.system(size: DS.IconSize.reg, weight: .medium))
                .foregroundStyle(DS.Colors.primary)
                .frame(width: DS.TouchTarget.comfortable, height: DS.TouchTarget.comfortable)
        } content: {
            DayProgressPopover(habit: habit, date: date, onAddProgress: onAddProgress)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}
