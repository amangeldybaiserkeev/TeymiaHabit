import SwiftUI

struct PremiumLockCapsule: View {
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "lock.fill")
                .font(.system(size: IconSize.xxs))

            Text("Premium")
                .font( .caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(PremiumGradientColors.gradient)
        .clipShape(.capsule)
    }
}

struct PremiumLockBadge: View {
    var size =  IconSize.sm

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
                .stroke(.onPrimary, lineWidth: 2)
                .frame(size: size)
        }
    }
}
