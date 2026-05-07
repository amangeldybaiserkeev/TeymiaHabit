import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        OnboardingContentView(
            items: [
                .init(
                    id: 0,
                    title: "",
                    subtitle: "",
                    screenshot: UIImage(
                        named: "Onboarding"
                    )
                ),
                .init(
                    id: 1,
                    title: "",
                    subtitle: "",
                    screenshot: UIImage(
                        named: "Onboarding1"
                    )
                ),
                .init(
                    id: 2,
                    title: "",
                    subtitle: "",
                    screenshot: UIImage(
                        named: "Onboarding2"
                    ),
                    zoomScale: 1.3,
                    zoomAnchor: .bottom
                ),
                .init(
                    id: 3,
                    title: "",
                    subtitle: "",
                    screenshot: UIImage(
                        named: "Onboarding3"
                    ),
                    zoomScale: 1.2,
                    zoomAnchor: .init(
                        x: 0.5,
                        y: -0.1
                    )
                ),
                .init(
                    id: 4,
                    title: "",
                    subtitle: "",
                    screenshot: UIImage(
                        named: "Onboarding4"
                    )
                )
            ]
        ) {
            if !hasCompletedOnboarding {
                withAnimation(DS.Animations.spring) {
                    hasCompletedOnboarding = true
                }
            } else {
                dismiss()
            }
        }
    }
}

struct OnboardingContentView: View {
    var tint = DS.Colors.primary
    var hideBezels: Bool = false
    var items: [Item]
    var onComplete: () -> Void

    @State private var currentIndex: Int = 0
    @State private var screenshotSize: CGSize = .zero

    private let animation = DS.Animations.snappy

    var body: some View {
        ZStack(alignment: .bottom) {
            ScreenshotView()
                .compositingGroup()
                .scaleEffect(
                    items[currentIndex].zoomScale,
                    anchor: items[currentIndex].zoomAnchor
                )
                .padding(.top, DS.Spacing.xxl)
                .padding(.horizontal, DS.Spacing.xxl)
                .padding(.bottom, 220)

            VStack(spacing: DS.Spacing.xs) {
                TextContentView()
                IndicatorView()
                ContinueButton()
            }
            .padding(.top, DS.Spacing.md)
            .padding(.horizontal, DS.Spacing.reg)
            .frame(height: 210)
            .background {
                VariableGlassBlur(15)
            }

            BackButton()
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func ScreenshotView() -> some View {
        let shape = ConcentricRectangle(corners: .concentric, isUniform: true)

        GeometryReader { geometry in
            let size = geometry.size

            Rectangle()
                .fill(.black)

            ScrollView(.horizontal) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]

                        Group {
                            if let screenshot = item.screenshot {
                                Image(uiImage: screenshot)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .onGeometryChange(for: CGSize.self) { geometry in
                                        geometry.size
                                    } action: { newValue in
                                        screenshotSize = newValue
                                    }
                                    .clipShape(shape)
                            } else {
                                Rectangle()
                                    .fill(.black)
                            }
                        }
                        .frame(width: size.width, height: size.height)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: {
                currentIndex
            }, set: { _ in }))
        }
        .clipShape(shape)
        .overlay {
            if screenshotSize != .zero && !hideBezels {
                ZStack {
                    shape
                        .stroke(.white, lineWidth: 6)

                    shape
                        .stroke(.black, lineWidth: 4)

                    shape
                        .stroke(.black, lineWidth: 6)
                        .padding(DS.Spacing.xxs)
                }
                .padding(-DS.Spacing.xxs)
            }
        }
        .frame(
            maxWidth: screenshotSize.width == 0 ? nil : screenshotSize.width,
            maxHeight: screenshotSize.height == 0 ? nil : screenshotSize.height
        )
        .containerShape(RoundedRectangle(cornerRadius: deviceCornerRadius))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func TextContentView() -> some View {
        GeometryReader { geometry in
            let size = geometry.size

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        let isActive = currentIndex == index

                        VStack(spacing: DS.Spacing.xs) {
                            Text(item.title)
                                .font(DS.AppFont.title2)
                                .lineLimit(1)
                                .foregroundStyle(DS.Colors.primary)

                            Text(item.subtitle)
                                .font(DS.AppFont.bodyMedium)
                                .lineLimit(2)
                                .foregroundStyle(DS.Colors.primary.opacity(0.8))
                        }
                        .frame(width: size.width)
                        .compositingGroup()
                        .blur(radius: isActive ? 0 : 30)
                        .opacity(isActive ? 1 : 0)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(true)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: .init(get: {
                currentIndex
            }, set: { _ in }))
        }
    }

    @ViewBuilder
    private func IndicatorView() -> some View {
        HStack(spacing: DS.Spacing.xs) {
            ForEach(items.indices, id: \.self) { index in
                let isActive: Bool = currentIndex == index

                Capsule()
                    .fill(.white.opacity(isActive ? 1 : 0.4))
                    .frame(width: isActive ? 25 : 6, height: 6)

            }
        }
        .padding(.bottom, DS.Spacing.xxs)
    }

    @ViewBuilder
    private func ContinueButton() -> some View {
        Button {
            if currentIndex == items.count - 1 {
                onComplete()
            }

            withAnimation(animation) {
                currentIndex = min(currentIndex + 1, items.count - 1)
            }
        } label: {
            Text(currentIndex == items.count - 1 ? "Get Started" : "Continue")
                .foregroundStyle(DS.Colors.onPrimary)
                .fontWeight(.medium)
                .contentTransition(.numericText())
                .padding(DS.Spacing.xs)
        }
        .tint(tint)
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .padding(.horizontal, DS.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func BackButton() -> some View {
        Button {
            withAnimation(animation) {
                currentIndex = max(currentIndex - 1, 0)
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .fontWeight(.medium)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, DS.Spacing.reg)
        .padding(.top, DS.Spacing.xxs)
    }

    @ViewBuilder
    private func VariableGlassBlur(_ radius: CGFloat) -> some View {
        let tint: Color = .black.opacity(0.4)
        Rectangle()
            .fill(.clear)
            .glassEffect(.clear.tint(tint), in: .rect)
            .blur(radius: radius)
            .padding([.horizontal, .bottom], -radius * 2)
            .padding(.top, -radius / 2)
            .opacity(items[currentIndex].zoomScale != 1 ? 1 : 0)
            .ignoresSafeArea()
    }

    private var deviceCornerRadius: CGFloat {
        if let imageSize = items.first?.screenshot?.size {
            let ratio = screenshotSize.height / imageSize.height
            let actualCornerRadius: CGFloat = 190
            return actualCornerRadius * ratio
        }

        return 0
    }

    struct Item: Identifiable {
        var id: Int
        var title: String
        var subtitle: String
        var screenshot: UIImage?
        var zoomScale: CGFloat = 1
        var zoomAnchor: UnitPoint = .center
    }
}

