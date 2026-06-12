import SwiftUI

struct StatsPeriodHeader: View {
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool

    var body: some View {
        ZStack {
            Text(title)
                .foregroundStyle(Color.primary)
                .font( .title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .contentTransition(.numericText())

            HStack {
                Spacer()

                HStack(spacing: Spacing.reg) {
                    ChevronButton(systemImage: "chevron.left", isEnabled: canGoPrevious) {
                        onPrevious()
                    }
                    ChevronButton(systemImage: "chevron.right", isEnabled: canGoNext) {
                        onNext()
                    }
                }
                .font(.system(size: IconSize.sm))
                .fontWeight(.semibold)
                .buttonStyle(.plain)
                .contentShape(.rect)
            }
        }
        .padding(.horizontal, Spacing.reg)
        .padding(.bottom, Spacing.reg)
    }
}

private struct ChevronButton: View {
    let systemImage: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation( Animations.easeInOut) {
                action()
            }
        } label: {
            Image(systemName: systemImage)
                .foregroundStyle(Color.secondary.opacity(0.7))
                .font(.system(size: IconSize.sm))
                .fontWeight(.semibold)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .contentShape(.rect)
    }
}
