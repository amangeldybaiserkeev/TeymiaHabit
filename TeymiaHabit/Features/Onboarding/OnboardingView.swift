import SwiftUI

struct OnboardingCard: Identifiable {
    let id = UUID()
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    private let tint = Color.primary
    private let secondary = Color.secondary

    let cards: [OnboardingCard] = [
        OnboardingCard(
            symbol: "checkmark.circle.dotted",
            title: "Build Lasting Habits",
            subtitle: "Count time, hit goals, and stay consistent with progress rings."
        ),
        OnboardingCard(
            symbol: "bell.badge",
            title: "Smart Reminders",
            subtitle: "Set flexible schedules and get notified on the days that matter to you."
        ),
        OnboardingCard(
            symbol: "chart.bar.xaxis",
            title: "See Your Progress",
            subtitle: "Weekly, monthly, and yearly charts show how far you've come."
        )
    ]

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Image("AppIconBlank")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: 100)
                .foregroundStyle(.main.gradient)
                .padding(.top, 60)

            VStack(spacing: Spacing.xxs) {
                Text("Welcome to")
                    .foregroundStyle(tint.gradient)
                    .minimumScaleFactor(0.8)
                Text("Teymia Habit")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint, secondary.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: Spacing.lg) {
                ForEach(cards) { card in
                    OnboardingCardView(card: card)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: Spacing.reg) {
                footerContent

                Button {
                    hasCompletedOnboarding = false
                } label: {
                    Text("Continue")
                        .font( .headline)
                        .foregroundStyle(.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: TouchTarget.minimum)
                }
                .tint(tint)
                .buttonStyle(.glassProminent)
                .sensoryFeedback(.selection, trigger: hasCompletedOnboarding)
            }
            .padding(.bottom, Spacing.reg)
        }
        .padding( Spacing.xxl)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity)
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    var footerContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: IconSize.md))
                .foregroundStyle(tint.gradient, secondary.opacity(0.5).gradient)
                .symbolRenderingMode(.palette)

            Text(
                "Your data never leaves your devices. Everything is stored locally and synced via iCloud."
            )
                .font( .footnote)
                .foregroundStyle(secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OnboardingCardView: View {
    let card: OnboardingCard

    var body: some View {
        HStack(spacing: Spacing.reg) {
            Image(systemName: card.symbol)
                .font(.system(size: IconSize.reg))
                .foregroundStyle(
                    Color.primary.gradient,
                    Color.secondary.gradient,
                )
                .symbolVariant(.fill)
                .symbolRenderingMode(.palette)
                .frame(width: Spacing.xxl)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(card.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(card.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.primary.opacity(0.7))
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
