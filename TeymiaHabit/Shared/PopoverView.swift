import SwiftUI

// TODO:

struct PopoverView<Label: View, Content: View>: View {
    @State private var haptic: Bool = false
    @State private var isExpanded: Bool = false
    
    @ViewBuilder var label: Label
    @ViewBuilder var content: Content
    
    @Namespace private var namespace
    
    var isHapticEnabled: Bool = true
    
    var body: some View {
        Button {
            if isHapticEnabled {
                haptic.toggle()
            }
            
            isExpanded.toggle()
        } label: {
            label
                .matchedTransitionSource(id: "POPOVER", in: namespace)
        }
        .buttonStyle(.glass)
        .popover(isPresented: $isExpanded) {
            PopOverHelper {
                content
            }
            .navigationTransition(.zoom(sourceID: "POPOVER", in: namespace))
        }
        .sensoryFeedback(.selection, trigger: haptic)
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
