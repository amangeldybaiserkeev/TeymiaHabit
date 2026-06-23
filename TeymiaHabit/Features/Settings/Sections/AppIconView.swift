import SwiftUI

struct AppIconRow: View {
    var body: some View {
        NavigationLink {
            AppIconView()
        } label: {
            SettingsRow(item: .appIcon)
        }
    }
}

struct AppIconFlowConfig {
    var iconWidth: CGFloat
    var rotation: CGFloat = 58
    var offsetFactor: CGFloat = 1.4
    var activeElevation: CGFloat = 0

    var reflectionGap: CGFloat = 0.5
    var reflectionFade: CGFloat = 6
    var reflectionDim: CGFloat = 0.6
}

struct AppIconFlow<Content: View>: View {
    var config: AppIconFlowConfig
    @Binding var activeIndex: Int?
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { proxy in
            let containerSize = proxy.size
            let currentIndex = activeIndex ?? 0

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    Group(subviews: content) { collection in
                        ForEach(collection.indices, id: \.self) { index in
                            let subview = collection[index]
                            let zIndex = currentIndex > index ? Double(index) : Double(-index)

                            subview
                                .frame(width: config.iconWidth, height: containerSize.height)
                                .visualEffect { [config] content, proxy in
                                    let values = retriveLayoutAdjustmentValues(proxy, config: config)

                                    return content
                                        .layerEffect(
                                            ShaderLibrary.appIconFlowReflection(
                                                .float(proxy.size.height),
                                                .float(config.reflectionGap),
                                                .float(config.reflectionFade),
                                                .float(config.reflectionDim)
                                            ),
                                            maxSampleOffset: proxy.size
                                        )
                                        .rotation3DEffect(
                                            .init(degrees: values.rotation),
                                            axis: (x: 0, y: 1, z: 0),
                                            anchor: values.anchor,
                                            anchorZ: values.anchorZ,
                                            perspective: 1
                                        )
                                        .offset(x: values.offset)
                                }
                                .zIndex(currentIndex == index ? 1000 : zIndex)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, (containerSize.width - config.iconWidth) / 2)
            .scrollPosition(id: $activeIndex, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
        }
    }

    nonisolated
    private func retriveLayoutAdjustmentValues(
        _ proxy: GeometryProxy,
        config: AppIconFlowConfig
    ) -> LayoutAdjustmentValues {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        let progress = minX / config.iconWidth
        let cappedProgress = max(-1, min(1, progress))
        let rotation = -cappedProgress * config.rotation
        let offset = -progress * (config.iconWidth / config.offsetFactor)
        let anchor: UnitPoint = cappedProgress < 0 ? .leading : .trailing
        let anchorZ = abs(cappedProgress) * config.activeElevation

        return LayoutAdjustmentValues(
            rotation: rotation,
            anchor: anchor,
            anchorZ: anchorZ,
            offset: offset
        )
    }
}

private struct LayoutAdjustmentValues {
    let rotation: CGFloat
    let anchor: UnitPoint
    let anchorZ: CGFloat
    let offset: CGFloat
}

struct AppIconView: View {
    @Environment(StoreKitService.self) private var storeKitService
    @State private var appIconManager = AppIconManager()
    @State private var activeIndex: Int?
    @State private var elevation: CGFloat = 35
    @State private var showingPaywall = false

    private static let lockBadgeOffset: CGFloat = 7

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                AppIconFlow(
                    config: .init(
                        iconWidth: 130,
                        activeElevation: elevation
                    ),
                    activeIndex: $activeIndex
                ) {
                    ForEach(AppIcon.allCases) { icon in
                        let isLocked = !storeKitService.canUseIcon(icon)
                        let isCurrent = appIconManager.currentIcon == icon

                        Button {
                            if isLocked {
                                showingPaywall = true
                            } else {
                                appIconManager.setAppIcon(icon)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    AppIconImage(icon: icon, size: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: Radius.xxl))

                                    if isLocked {
                                        PremiumLockBadge(size: IconSize.lg)
                                            .offset(x: Self.lockBadgeOffset, y: -Self.lockBadgeOffset)
                                    }
                                }

                                Capsule()
                                    .fill(isCurrent ? Color.indigo : Color.clear)
                                    .frame(width: isCurrent ? 40 : 0, height: 3)
                                    .offset(y: 6) // <- смещаем вниз на 6 пунктов
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
                            }
                            .frame(size: 130)
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut, value: isCurrent)
                    }
                }
                .frame(height: 125)
                .offset(y: 8)
                .zIndex(1)

                ShelfPlatform()
            }
            .padding(.bottom, Spacing.xxl)

            if let currentIndex = activeIndex,
               let icon = AppIcon.allCases[safe: currentIndex] {
                Text(icon.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.appPrimary)
                    .padding(.bottom, Spacing.xxl)
                    .contentTransition(.numericText())
            }

            PageIndicator(
                numberOfPages: AppIcon.allCases.count,
                currentPage: activeIndex ?? 0
            )
            .padding(.bottom, Spacing.xxl)

            if let currentIndex = activeIndex {
                let icon = AppIcon.allCases[currentIndex]
                let isLocked = !storeKitService.canUseIcon(icon)
                let isCurrent = appIconManager.currentIcon == icon
                let buttonState = isLocked ? ButtonState.locked : (isCurrent ? .selected : .available)

                Button {
                    if isLocked {
                        showingPaywall = true
                    } else {
                        appIconManager.setAppIcon(icon)
                    }
                } label: {
                    SelectButtonContent(state: buttonState)
                }
                .disabled(isCurrent)
                .glassEffect(.regular.interactive(), in: .capsule)
                .padding(.horizontal, Spacing.lg)
            }
        }
        .navigationTitle("App Icon")
        .animation(Animations.easeInOut, value: appIconManager.currentIcon)
        .animation(Animations.easeInOut, value: activeIndex)
        .onAppear {
            appIconManager.syncWithSystem()
            if let index = AppIcon.allCases.firstIndex(of: appIconManager.currentIcon) {
                activeIndex = index
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

private struct SelectButtonContent: View {
    let state: ButtonState

    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(Spacing.reg)
            .background(backgroundView)
            .clipShape(.capsule)
    }

    private var title: LocalizedStringKey {
        switch state {
        case .locked: return "Unlock"
        case .selected: return "Selected"
        case .available: return "Select"
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .locked: return .white
        case .selected: return .black
        case .available: return .onPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch state {
        case .locked:
            PremiumGradientColors.gradient
        case .selected:
            Color.appTertiary
        case .available:
            Color.appPrimary
        }
    }
}

enum ButtonState {
    case locked
    case selected
    case available
}

private struct AppIconImage: View {
    let icon: AppIcon
    var size: CGFloat

    var body: some View {
        Image(icon.previewImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

struct ShelfPlatform: View {
    var topHeight: CGFloat = 44
    var faceHeight: CGFloat = 16
    var horizontalPadding: CGFloat = 16
    var skewAngle: CGFloat = 0.16

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let topOffset = (topHeight + faceHeight) * skewAngle * 3.5
            let bottomOffset = (topHeight + faceHeight) * skewAngle * 0.1

            Path { path in
                path.move(to: CGPoint(x: topOffset, y: 0))
                path.addLine(to: CGPoint(x: width - topOffset, y: 0))
                path.addLine(to: CGPoint(x: width - bottomOffset, y: topHeight))
                path.addLine(to: CGPoint(x: bottomOffset, y: topHeight))
                path.closeSubpath()
            }
            .fill(Color.white)

            Path { path in
                path.move(to: CGPoint(x: bottomOffset, y: topHeight))
                path.addLine(to: CGPoint(x: width - bottomOffset, y: topHeight))
            }
            .stroke(Color(white: 0.68), lineWidth: 1)

            Path { path in
                let frontTopOffset = (topHeight + faceHeight) * skewAngle * 2.0
                let frontBottomOffset = (topHeight + faceHeight) * skewAngle * 0.2

                path.move(to: CGPoint(x: bottomOffset, y: topHeight))
                path.addLine(to: CGPoint(x: width - bottomOffset, y: topHeight))
                path.addLine(to: CGPoint(x: width - frontBottomOffset, y: topHeight + faceHeight))
                path.addLine(to: CGPoint(x: frontBottomOffset, y: topHeight + faceHeight))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color(white: 0.86), location: 0),
                        .init(color: Color(white: 0.94), location: 0.35),
                        .init(color: Color(white: 0.98), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: topHeight + faceHeight + 1)
        .padding(.horizontal, horizontalPadding)
        .shadow(color: .black.opacity(0.22), radius: 40, x: 0, y: 22)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? .appPrimary : .appSecondary.opacity(0.3))
                    .frame(size: 8)
                    .animation(.smooth, value: currentPage)
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        AppIconView()
            .environment(StoreKitService())
    }
}
