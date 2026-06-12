import SwiftUI

struct LinearGradientBackground: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)

            LinearGradient(
                colors: [
                    .indigo.opacity(0.3),
                    .indigo.opacity(0.1),
                    .clear,
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}
