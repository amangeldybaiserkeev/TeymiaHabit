import SwiftUI

extension View {
    // isPresented
    @ViewBuilder
    func adaptiveSheet(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            self.sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
        } else {
            self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: content)
        }
    }

    // Item
    @ViewBuilder
    func adaptiveSheet<Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            self.sheet(item: item, onDismiss: onDismiss, content: content)
        } else {
            self.fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        }
    }
}
