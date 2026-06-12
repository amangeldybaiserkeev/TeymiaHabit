import SwiftUI

struct LivelyFloatingBlobsBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                ForEach(BlobConfiguration.all) { config in
                    LivelyBlob(
                        configuration: config,
                        containerSize: geo.size
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct BlobConfiguration: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let waypoints: [RelativeWaypoint]
    let duration: TimeInterval
    let delay: TimeInterval

    struct RelativeWaypoint {
        let x: CGFloat
        let y: CGFloat

        func absolutePoint(in size: CGSize) -> CGPoint {
            CGPoint(x: size.width * x, y: size.height * y)
        }
    }
}

private extension BlobConfiguration {
    static var purple: BlobConfiguration {
        BlobConfiguration(
            color: .blobPurple.opacity(0.3),
            size: 210,
            waypoints: [
                .init(x: 0.15, y: 0.2),
                .init(x: 0.25, y: 0.4),
                .init(x: 0.20, y: 0.7),
                .init(x: 0.30, y: 0.55),
                .init(x: 0.18, y: 0.35)
            ],
            duration: 4,
            delay: 0
        )
    }

    static var blue: BlobConfiguration {
        BlobConfiguration(
            color: .blobBlue.opacity(0.5),
            size: 190,
            waypoints: [
                .init(x: 0.75, y: 0.25),
                .init(x: 0.85, y: 0.5),
                .init(x: 0.80, y: 0.75),
                .init(x: 0.70, y: 0.6),
                .init(x: 0.82, y: 0.4)
            ],
            duration: 5,
            delay: 0.5
        )
    }

    static var indigo: BlobConfiguration {
        BlobConfiguration(
            color: .blobIndigo.opacity(0.5),
            size: 170,
            waypoints: [
                .init(x: 0.50, y: 0.3),
                .init(x: 0.55, y: 0.5),
                .init(x: 0.50, y: 0.7),
                .init(x: 0.45, y: 0.5)
            ],
            duration: 3,
            delay: 1.0
        )
    }

    static var all: [BlobConfiguration] {
        [.purple, .blue, .indigo]
    }
}

// MARK: - Lively Blob
private struct LivelyBlob: View {
    let configuration: BlobConfiguration
    let containerSize: CGSize

    @State private var currentWaypointIndex = 0
    @State private var animating = false

    var body: some View {
        Circle()
            .fill(blobGradient)
            .frame(size: configuration.size)
            .blur(radius: 60)
            .position(currentPosition)
            .onAppear {
                guard !animating else { return }
                animating = true
                moveToNextWaypoint()
            }
    }

    private var absolutePositions: [CGPoint] {
        configuration.waypoints.map { $0.absolutePoint(in: containerSize) }
    }

    private var currentPosition: CGPoint {
        absolutePositions[currentWaypointIndex % absolutePositions.count]
    }

    private var blobGradient: RadialGradient {
            RadialGradient(
                colors: [
                    configuration.color,
                    configuration.color.opacity(0.7),
                    configuration.color.opacity(0.4),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: configuration.size / 2
            )
        }

        private func moveToNextWaypoint() {
            let nextIndex = (currentWaypointIndex + 1) % absolutePositions.count

            withAnimation(
                .easeInOut(duration: configuration.duration)
                .delay(currentWaypointIndex == 0 ? configuration.delay : 0)
            ) {
                currentWaypointIndex = nextIndex
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(configuration.duration))
                guard animating else { return }
                moveToNextWaypoint()
            }
        }
}

private extension Color {
    static let blobPurple = Color(#colorLiteral(red: 0.7803921569, green: 0.3803921569, blue: 0.7568627451, alpha: 1))
    static let blobBlue = Color(#colorLiteral(red: 0.4235294118, green: 0.5764705882, blue: 0.9960784314, alpha: 1))
    static let blobIndigo = Color(#colorLiteral(red: 0.4925274849, green: 0.5225450397, blue: 0.9995061755, alpha: 1))
}

#Preview {
    LivelyFloatingBlobsBackground()
}
