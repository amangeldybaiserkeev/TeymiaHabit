import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let currentValue: String
    let isCompleted: Bool
    let isExceeded: Bool
    let habit: Habit
    let size: CGFloat

    var isTimerRunning: Bool = false
    var lineWidth: CGFloat?
    var hideContent: Bool = false

    private enum Metrics {
        // Dimensions
        static let ringLineWidthRatio: CGFloat = 0.12
        static let checkmarkSizeRatio: CGFloat = 0.4
        static let iconSizeRatio: CGFloat = 0.35
        static let textSizeRatio: CGFloat = 0.2
        static let textFrameWidthRatio: CGFloat = 0.65
        static let textFrameHeightRatio: CGFloat = 0.35
        static let minimumScaleFactor: CGFloat = 0.3
        static let lineLimit: Int = 1

        // Progress Logic
        static let trimStart: CGFloat = 0
        static let trimEnd: CGFloat = 1.0
        static let overflowThreshold: Double = 1.0

        // Angles
        static let startAngle: Double = -90
        static let fullCircle: Double = 360
        static let gradientEndAngle: Double = 270

        // Visuals
        static let capShadowColor = Color.black.opacity(0.07)
        static let capShadowRadius: CGFloat = 4
        static let capShadowXOffsetRatio: CGFloat = 2.5

        // Behavior
        static let iconReplaceSpeed: Double = 1.5
        static let compactSizeBreakpoint: CGFloat = 80
        static let animation: Animation =  Animations.easeInOut
    }

    // MARK: - Computed Properties
    private var adaptiveLineWidth: CGFloat {
        lineWidth ?? (size * Metrics.ringLineWidthRatio)
    }

    private var clampedProgress: CGFloat {
        CGFloat(min(max(progress, 0), Metrics.overflowThreshold))
    }

    private var ringColors: (dark: Color, light: Color) {
        habit.ringColors
    }

    private var formattedText: String {
        let value = Int(currentValue) ?? 0
        switch habit.type {
        case .count: return "\(value)"
        case .time: return value.formattedAsTime()
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Circle()
                .stroke(.appTertiary, lineWidth: adaptiveLineWidth)

            mainProgressRing

            overflowRingGroup
                .opacity(progress > Metrics.overflowThreshold ? 1 : 0)

            if !hideContent {
                ringContent
            }
        }
        .frame(size: size)
    }
}

// MARK: - Subviews
private extension ProgressRing {
    var mainProgressRing: some View {
        Circle()
            .trim(from: Metrics.trimStart, to: clampedProgress)
            .stroke(
                AngularGradient(
                    colors: [ringColors.light, ringColors.dark, ringColors.dark, ringColors.light],
                    center: .center,
                    startAngle: .degrees(Metrics.startAngle),
                    endAngle: .degrees(Metrics.gradientEndAngle)
                ),
                style: StrokeStyle(lineWidth: adaptiveLineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(Metrics.startAngle))
            .animation(Metrics.animation, value: progress)
    }

    var overflowRingGroup: some View {
        Group {
            Circle()
                .trim(from: Metrics.trimStart, to: clampedProgress)
                .stroke(
                    AngularGradient(colors: [ringColors.dark, ringColors.light], center: .center),
                    style: StrokeStyle(lineWidth: adaptiveLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(Metrics.startAngle))
                .rotationEffect(.degrees(Metrics.fullCircle * (progress - Metrics.overflowThreshold)))

            ZStack {
                Circle()
                    .frame(size: adaptiveLineWidth)
                    .offset(y: -size / 2)
                    .foregroundStyle(ringColors.light)
                    .mask {
                        LinearGradient(
                            colors: [.clear, .white, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        frame(size: adaptiveLineWidth)
                        .offset(y: -size / 2)
                    }
                    .shadow(
                        color: Metrics.capShadowColor,
                        radius: Metrics.capShadowRadius,
                        x: adaptiveLineWidth / Metrics.capShadowXOffsetRatio,
                        y: 0
                    )
                    .rotationEffect(.degrees(Metrics.fullCircle * progress))
            }
        }
        .animation(Metrics.animation, value: progress)
    }

    @ViewBuilder
    var ringContent: some View {
        if size < Metrics.compactSizeBreakpoint {
            compactContent
        } else {
            detailContent
        }
    }

    @ViewBuilder
    var compactContent: some View {
        let iconName = isCompleted || isExceeded
        ? "checkmark"
        : (habit.type == .count ? "plus" : (isTimerRunning ? "pause.fill" : "play.fill"))

        Image(systemName: iconName)
            .font(.system(size: size * Metrics.iconSizeRatio, weight: .bold))
            .foregroundStyle(
                isCompleted || isExceeded
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [ringColors.light, ringColors.dark],
                        startPoint: .topTrailing, endPoint: .bottomLeading
                    )
                )
                : AnyShapeStyle(Color.primary)
            )
            .contentTransition(.symbolEffect(.replace))
            .animation(Metrics.animation, value: isCompleted)
            .animation(Metrics.animation, value: isExceeded)
            .animation(Metrics.animation, value: isTimerRunning)
    }

    @ViewBuilder
    var detailContent: some View {
        progressValueText
    }

    var progressValueText: some View {
        Text(formattedText)
            .font(.system(size: size * Metrics.textSizeRatio, weight: .bold).monospacedDigit())
            .minimumScaleFactor(Metrics.minimumScaleFactor)
            .lineLimit(Metrics.lineLimit)
            .frame(width: size * Metrics.textFrameWidthRatio, height: size * Metrics.textFrameHeightRatio)
            .contentTransition(.numericText())
            .animation( Animations.bouncy, value: currentValue)
    }
}

#Preview {
    let habit = Habit(
        title: "Exercise",
        type: .count,
        goal: 10,
        iconName: "book",
        iconColor: .lusciousLime,
        source: .manual
    )

    let size: CGFloat = 200

    VStack(spacing: 60) {
        ProgressRing(
            progress: 0.95,
            currentValue: "7",
            isCompleted: false,
            isExceeded: false,
            habit: habit,
            size: size
        )
        ProgressRing(
            progress: 1.95,
            currentValue: "7",
            isCompleted: false,
            isExceeded: false,
            habit: habit,
            size: size
        )
        ProgressRing(
            progress: 1.1,
            currentValue: "7",
            isCompleted: false,
            isExceeded: false,
            habit: habit,
            size: size
        )
    }
}
