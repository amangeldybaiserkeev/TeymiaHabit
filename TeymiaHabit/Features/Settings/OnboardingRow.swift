import SwiftUI

struct OnboardingRow: View {
    @State private var showOnboarding = false

    var body: some View {
        Button {
            showOnboarding = true
        } label: {
            Label {
                Text("show_onboarding")
                    .foregroundStyle(DS.Colors.primary)
            } icon: {
                RowIcon(iconName: "hand.wave", color: .appCoral)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}
