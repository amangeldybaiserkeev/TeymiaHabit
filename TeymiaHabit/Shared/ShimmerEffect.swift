import SwiftUI

// MARK: - Configuration
struct ShimmerConfig {
    var highlight: Color = .white
    var blur: CGFloat = 15
    var highlightOpacity: CGFloat = 0.4
    var speed: CGFloat = 1
    var delay: Double = 4
    var startOffset: CGFloat = -1.5
    var endOffset: CGFloat = 1.5
    var rotationDegrees: Double = -20
}

extension View {
    @ViewBuilder
    func shimmer(_ config: ShimmerConfig) -> some View {
        modifier(ShimmerEffectHelper(config: config))
    }
}

// MARK: - Shimmer Effect Helper
private struct ShimmerEffectHelper: ViewModifier {
    let config: ShimmerConfig

    func body(content: Content) -> some View {
        content
            .overlay {
                ShimmerView(config: config)
                    .mask(content)
            }
    }
}

// MARK: - Shimmer View
private struct ShimmerView: View {
    let config: ShimmerConfig
    @State private var moveTo: CGFloat

    init(config: ShimmerConfig) {
        self.config = config
        _moveTo = State(initialValue: config.startOffset)
    }

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(shimmerGradient)
                .blur(radius: config.blur)
                .rotationEffect(.init(degrees: config.rotationDegrees))
                .offset(x: geo.size.width * moveTo)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear(perform: startAnimation)
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0),
                config.highlight.opacity(config.highlightOpacity),
                .white.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func startAnimation() {
        withAnimation(
            .linear(duration: config.speed)
                .delay(config.delay)
                .repeatForever(autoreverses: false)
        ) {
            moveTo = config.endOffset
        }
    }
}
