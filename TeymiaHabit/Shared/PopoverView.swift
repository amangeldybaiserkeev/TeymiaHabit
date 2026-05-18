import SwiftUI

struct PopoverView<Label: View, Content: View>: View {
    @ViewBuilder var label: Label
    @ViewBuilder var content: Content

    @State private var haptic: Bool = false
    @State private var isExpanded: Bool = false

    @Namespace private var namespace

    var body: some View {
        Button {
            isExpanded.toggle()
        } label: {
            label
                .matchedTransitionSource(id: "POPOVER", in: namespace)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isExpanded) {
            PopOverHelper {
                content
            }
            #if !targetEnvironment(macCatalyst)
            .navigationTransition(.zoom(sourceID: "POPOVER", in: namespace))
            #endif
        }
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
}

private struct PopOverHelper<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var isVisible: Bool = false

    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .task {
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(DS.Animations.snappy) {
                    isVisible = true
                }
            }
            .presentationCompactAdaptation(.popover)
    }
}
