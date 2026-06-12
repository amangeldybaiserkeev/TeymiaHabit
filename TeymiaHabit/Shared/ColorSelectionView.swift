import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColor: HabitIconColor

    private enum Layout {
        static let buttonSize = IconSize.lg
        static let fadeWidth: Double = 0.05
        static let threshold: CGFloat = 0.8
        static let minScale: CGFloat = 0.4
        static let selectionScale: CGFloat = 1.15
        static let innerStrokeScale: CGFloat = 0.9

        static var innerStrokeSize: CGFloat {
            buttonSize * innerStrokeScale
        }
    }

    var body: some View {
        HStack {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Spacing.reg) {
                        ForEach(HabitIconColor.allCases, id: \.self) { iconColor in
                            colorButton(for: iconColor, in: geo)
                        }
                    }
                    .padding(.horizontal, Spacing.reg)
                }
                .mask {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: Layout.fadeWidth),
                            .init(color: .black, location: 1 - Layout.fadeWidth),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            }
        }
        .frame(height: Layout.buttonSize * 2)
        .glassEffect(.regular, in: .capsule)
        .sensoryFeedback(.selection, trigger: selectedColor)
        .clipShape(.capsule)
    }

    private func colorButton(for color: HabitIconColor, in geo: GeometryProxy) -> some View {
        let isSelected = selectedColor == color

        return GeometryReader { itemGeo in
            // Calculate relative position and distance from center
            let midX = itemGeo.frame(in: .global).midX
            let leftEdge = geo.frame(in: .global).minX
            let rightEdge = geo.frame(in: .global).maxX
            let centerX = (leftEdge + rightEdge) / 2

            let distanceFromCenter = abs(midX - centerX)
            let maxDistance = (rightEdge - leftEdge) / 2
            let normalized = distanceFromCenter / maxDistance

            // Calculate effect intensity (only trigger in outer 20% of the view)
            let rawFactor = (normalized - Layout.threshold) / (1 - Layout.threshold)
            let edgeFactor = max(0, rawFactor)

            // Apply visual transforms
            let scale = 1.0 - edgeFactor * Layout.minScale
            let opacity = 1.0 - edgeFactor

            Button {
                withAnimation(Animations.spring) {
                    selectedColor = color
                }
            } label: {
                Circle()
                    .fill(color.baseColor)
                    .frame(size: Layout.buttonSize)
                    .overlay(
                        Circle()
                            .strokeBorder(.onPrimary, lineWidth: 2)
                            .frame(size: Layout.innerStrokeSize)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .scaleEffect(isSelected ? scale * Layout.selectionScale : scale)
                    .opacity(opacity)
            }
            .buttonStyle(.plain)
            .contentShape(.circle)
        }
        .frame(size: Layout.buttonSize)
    }
}
