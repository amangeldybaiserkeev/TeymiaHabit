import SwiftUI

struct PremiumLockCapsule: View {
    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            Image(systemName: "lock.fill")
                .font(.system(size: DS.IconSize.xxs))
            
            Text("PRO")
                .font(DS.AppFont.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.vertical, DS.Spacing.xxs)
        .background(PremiumGradientColors.gradient)
        .clipShape(Capsule())
    }
}

struct PremiumLockBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(PremiumGradientColors.gradient)
                .frame(size: DS.IconSize.sm)
            
            Image(systemName: "lock.fill")
                .font(.system(size: DS.IconSize.xxs))
                .foregroundStyle(.white)
        }
        .overlay {
            Circle()
                .stroke(Color(.secondarySystemGroupedBackground), lineWidth: 2)
                .frame(size: DS.IconSize.sm)
        }
    }
}
