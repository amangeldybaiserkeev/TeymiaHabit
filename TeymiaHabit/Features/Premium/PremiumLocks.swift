import SwiftUI

struct PremiumLockCapsule: View {
    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            Image(systemName: "lock.fill")
                .font(.system(size: DS.IconSize.xxs))

            Text("Premium")
                .font(DS.AppFont.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.vertical, DS.Spacing.xxs)
        .background(PremiumGradientColors.gradient)
        .clipShape(.capsule)
    }
}

struct PremiumLockBadge: View {
    var size = DS.IconSize.sm

    var body: some View {
        ZStack {
            Circle()
                .fill(PremiumGradientColors.gradient)
                .frame(size: size)

            Image(systemName: "lock.fill")
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(.white)
        }
        .overlay {
            Circle()
                .stroke(DS.Colors.onPrimary, lineWidth: 2)
                .frame(size: size)
        }
    }
}
