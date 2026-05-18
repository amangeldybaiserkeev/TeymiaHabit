import SwiftUI

extension View {
    func adaptiveFullScreen(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
#if targetEnvironment(macCatalyst)
        self.sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
#else
        self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss) {
            AdaptiveWrapper { content() }
        }
#endif
    }
}

private struct AdaptiveWrapper<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let content: () -> Content

    var body: some View {
        content()
            .environment(\.adaptiveWidth, sizeClass == .regular ? 500 : nil)
    }
}

// MARK: EnvironmentKey

struct AdaptiveWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var adaptiveWidth: CGFloat? {
        get { self[AdaptiveWidthKey.self] }
        set { self[AdaptiveWidthKey.self] = newValue }
    }
}

// MARK: - Extension
extension View {
    func applyAdaptiveWidth() -> some View {
        modifier(AdaptiveWidthModifier())
    }
}

struct AdaptiveWidthModifier: ViewModifier {
    @Environment(\.adaptiveWidth) var manualMaxWidth
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var finalMaxWidth: CGFloat? {
        if let manualMaxWidth { return manualMaxWidth }

        if sizeClass == .regular { return 700 }

        return nil
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: finalMaxWidth ?? .infinity)
            .frame(maxWidth: .infinity)
    }
}
