import SwiftUI

struct PremiumRow: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var showingPaywall = false
    
    enum GradientPhase: CaseIterable {
        case first, second, third
        
        var colors: [Color] {
            switch self {
            case .first: return [Color(#colorLiteral(red: 0.4235294118, green: 0.5764705882, blue: 0.9960784314, alpha: 1)), Color(#colorLiteral(red: 0.7803921569, green: 0.3803921569, blue: 0.7568627451, alpha: 1))]
            case .second: return [Color(#colorLiteral(red: 0.3181028366, green: 0.5400418043, blue: 0.9980412126, alpha: 1)), Color(#colorLiteral(red: 0.5766596198, green: 0.4650856853, blue: 0.9760690331, alpha: 1))]
            case .third: return [Color(#colorLiteral(red: 0.4936487675, green: 0.5068361759, blue: 0.9980413318, alpha: 1)), Color(#colorLiteral(red: 0.8374075294, green: 0.424548924, blue: 0.8359348178, alpha: 1))]
            }
        }
    }
    
    var body: some View {
        Section {
#if DEBUG
            Button("Toggle Premium") {
                appContainer.storeKitService.toggleDebugPremium()
            }
            .buttonStyle(.glass)
#endif
            
            if !appContainer.storeKitService.isPremium {
                premiumRowView
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
    
    private var premiumRowView: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack {
                Image(systemName: "sparkles.2")
                    .font(.system(size: DS.IconSize.reg))
                    .foregroundStyle(.white.gradient)
                    .symbolEffect(.wiggle, options: .repeat(.periodic(delay: 4)))
                
                VStack(alignment: .leading) {
                    Text("Premium")
                        .font(DS.AppFont.headline)
                        .foregroundStyle(.white.gradient)
                    
                    HStack(spacing: DS.Spacing.xxs) {
                        Text("Try")
                            .foregroundStyle(.white.opacity(0.8))
                        Text("free")
                            .foregroundStyle(.white.gradient)
                        Text("for 7 days")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(DS.AppFont.subheadline)
                }
                Spacer()
                tryNowText
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(DS.Spacing.reg)
            .background {
                ZStack {
                    Color.clear
                        .phaseAnimator(GradientPhase.allCases) { content, phase in
                            content
                                .background {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: phase.colors,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                        } animation: { _ in
                                .easeInOut(duration: 5).delay(3)
                        }
                    
                    ForEach(0..<15, id: \.self) { _ in
                        FloatingStar(baseOffsetX: CGFloat.random(in: 50...150))
                    }
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.2),
                                            .white.opacity(0.2),
                                            .white.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        }
                        .blendMode(.overlay)
                }
            }
            .shimmer(.init())
        }
        .buttonStyle(.plain)
    }
}

private var tryNowText: some View {
    Text("Try Now")
        .font(DS.AppFont.headline)
        .foregroundStyle(.white.gradient)
        .minimumScaleFactor(0.8)
        .lineLimit(1)
        .padding(.vertical, DS.Spacing.xs)
        .padding(.horizontal, DS.Spacing.sm)
        .glassEffect(.clear.interactive(), in: .capsule)
}

private struct FloatingStar: View {
    @State private var offset = CGSize.zero
    @State private var opacity: Double = 0.5
    @State private var isAnimating = false
    
    let baseOffsetX: CGFloat
    
    private let starSize: CGFloat = CGFloat.random(in: 3...6)
    private let offsetRange: CGFloat = CGFloat.random(in: 40...120)
    private let angle = Angle.degrees(Double.random(in: 0...360))
    private let delay: Double = Double.random(in: 0...3)
    
    init(baseOffsetX: CGFloat = 0) {
        self.baseOffsetX = baseOffsetX
    }
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: starSize))
            .foregroundStyle(.white.opacity(opacity))
            .offset(x: baseOffsetX + offset.width, y: offset.height)
            .onAppear {
                withAnimation(
                    .spring(
                        response: Double.random(in: 4...8),
                        dampingFraction: 0.7,
                        blendDuration: 1
                    )
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: cos(angle.radians) * offsetRange,
                        height: sin(angle.radians) * offsetRange
                    )
                }
                
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...5))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 0.15
                }
            }
    }
}

#Preview {
    let container = PreviewContainer.container
    let appContainer = AppDependencyContainer(modelContext: container.mainContext)
    appContainer.storeKitService.setDebugPremium(false)
    return List {
        PremiumRow()
        
        Section {
            Text("Appearance")
            Text("App Tint")
            Text("App Icon")
        }
    }
    .environment(appContainer)
    .modelContainer(container)
}
