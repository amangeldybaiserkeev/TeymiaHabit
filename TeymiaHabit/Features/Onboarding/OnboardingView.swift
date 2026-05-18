import SwiftUI

struct OnboardingCard: Identifiable {
    let id = UUID()
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let primaryColor: Color
    let secondaryColor: Color
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    private static let tint = DS.Colors.primary
    private static let secondary = DS.Colors.secondary

    let cards: [OnboardingCard] = [
        OnboardingCard(
            symbol: "checkmark.circle.dotted",
            title: "Build Lasting Habits",
            subtitle: "Count time, hit goals, and stay consistent with progress rings.",
            primaryColor: tint,
            secondaryColor: secondary
        ),
        OnboardingCard(
            symbol: "bell.badge",
            title: "Smart Reminders",
            subtitle: "Set flexible schedules and get notified on the days that matter to you.",
            primaryColor: secondary,
            secondaryColor: tint
        ),
        OnboardingCard(
            symbol: "chart.bar.xaxis",
            title: "See Your Progress",
            subtitle: "Weekly, monthly, and yearly charts show how far you've come.",
            primaryColor: tint,
            secondaryColor: secondary
        )
    ]

    var body: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Image("Preview-AppIcon")
                .resizable()
                .frame(size: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(DS.Colors.secondary.opacity(0.15), lineWidth: 0.8)
                )
                .padding(.top, 60)

            VStack(spacing: DS.Spacing.xxs) {
                Text("Welcome to")
                    .foregroundStyle(Self.tint.gradient)
                    .minimumScaleFactor(0.8)
                Text("Teymia Habit")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Self.tint, Self.secondary.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .font(DS.AppFont.largeTitle)

            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                ForEach(cards) { card in
                    OnboardingCardView(card: card)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: DS.Spacing.reg) {
                footerContent

                Button {
                    hasCompletedOnboarding = false
                } label: {
                    Text("Continue")
                        .font(DS.AppFont.headline)
                        .foregroundStyle(DS.Colors.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.TouchTarget.minimum)
                }
                .tint(Self.tint)
                .buttonStyle(.glassProminent)
                .sensoryFeedback(.selection, trigger: hasCompletedOnboarding)
            }
            .padding(.bottom, DS.Spacing.reg)
        }
        .padding(DS.Spacing.xxl)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity)
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    var footerContent: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: DS.IconSize.md))
                .foregroundStyle(Self.tint.gradient, Self.secondary.opacity(0.5).gradient)
                .symbolRenderingMode(.palette)

            Text(
                "Your data never leaves your devices. Everything is stored locally and synced via iCloud."
            )
                .font(DS.AppFont.footnote)
                .foregroundStyle(Self.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OnboardingCardView: View {
    let card: OnboardingCard

    var body: some View {
        HStack(spacing: DS.Spacing.reg) {
            Image(systemName: card.symbol)
                .font(.system(size: DS.IconSize.reg))
                .foregroundStyle(
                    card.primaryColor.gradient,
                    card.secondaryColor.gradient,
                )
                .symbolVariant(.fill)
                .symbolRenderingMode(.palette)
                .frame(width: DS.Spacing.xxl)

            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(card.title)
                    .font(DS.AppFont.headline)
                    .lineLimit(1)
                Text(card.subtitle)
                    .font(DS.AppFont.subheadline)
                    .foregroundStyle(DS.Colors.primary.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    struct OnboardingPreviewContainer: View {
        @State private var showOnboarding = true

        var body: some View {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView(hasCompletedOnboarding: .constant(false))
                }
        }
    }

    return OnboardingPreviewContainer()
}
