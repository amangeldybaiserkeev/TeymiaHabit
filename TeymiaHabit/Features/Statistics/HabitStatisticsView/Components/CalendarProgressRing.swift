import SwiftUI

struct CalendarProgressRing: View {
    let progress: Double
    let ringColors: (dark: Color, light: Color)
    let size: CGFloat
    let lineWidth: CGFloat

    private var clampedProgress: CGFloat {
        CGFloat(min(max(progress, 0), 1.0))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.1), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(
                        colors: [ringColors.light, ringColors.dark, ringColors.dark, ringColors.light],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation( Animations.easeInOut, value: progress)
        }
        .frame(size: size)
    }
}
