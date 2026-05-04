import SwiftUI

protocol AnimatedTabSelectionProtocol: CaseIterable, Hashable {
    var title: LocalizedStringResource { get }
    var symbolImage: String { get }
}

/// Custom tab bar with symbol effects on selection.
/// Uses UIKit to access UIImageView and apply SymbolEffect.
struct AnimatedTabView<Selection: AnimatedTabSelectionProtocol, Content: TabContent<Selection>>: View {
    @Binding var selection: Selection
    @TabContentBuilder<Selection> var content: () -> Content

    @State private var imageViews: [Selection: UIImageView] = [:]

    var effects: (Selection) -> [any DiscreteSymbolEffect & SymbolEffect]

    var body: some View {
        TabView(selection: $selection) {
            content()
        }
        .background(ExtractImageViewsFromTabBar { views in
            imageViews = views
        })
        .compositingGroup()
        .onChange(of: selection) { _, newValue in
            let symbolEffects = effects(newValue)
            guard let imageView = imageViews[newValue] else { return }

            for effect in symbolEffects {
                imageView.addSymbolEffect(effect, options: .nonRepeating)
            }
        }
    }
}

// MARK: - UIImageView Extractor

/// Invisible view that finds UIImageView inside UITabBar.
private struct ExtractImageViewsFromTabBar<Selection: AnimatedTabSelectionProtocol>: UIViewRepresentable {
    var result: ([Selection: UIImageView]) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)

        Task { @MainActor [weak view] in
            guard let view else { return }
            try? await Task.sleep(for: .milliseconds(100))
            await extractTabBarImages(from: view)
        }

        return view
    }

    @MainActor
    private func extractTabBarImages(from view: UIView) async {
        try? await Task.sleep(for: .milliseconds(50))

        guard let tabBarController = findTabBarController(in: view) else { return }
        let imageViews = extractImageViews(from: tabBarController.tabBar, for: Selection.allCases)
        result(imageViews)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    private func findTabBarController(in view: UIView) -> UITabBarController? {
        var responder = view.next
        while responder != nil {
            if let tabController = responder as? UITabBarController {
                return tabController
            }
            responder = responder?.next
        }

        return view.superview?.superview?.subviews.last?
            .subviews.first?.next as? UITabBarController
    }

    private func extractImageViews(
        from tabBar: UITabBar,
        for tabs: Selection.AllCases
    ) -> [Selection: UIImageView] {
        let imageViews = tabBar.subviews(type: UIImageView.self)
            .filter { $0.image?.isSymbolImage ?? false }

        var dict: [Selection: UIImageView] = [:]

        for tab in tabs {
            if let imageView = findImageView(for: tab, in: imageViews) {
                dict[tab] = imageView
            }
        }

        return dict
    }

    private func findImageView(
        for tab: Selection,
        in imageViews: [UIImageView]
    ) -> UIImageView? {
        imageViews.first { view in
            view.description.contains(tab.symbolImage)
        }
    }
}

// MARK: - UIView Recursive Subviews

fileprivate extension UIView {
    func subviews<T: UIView>(type: T.Type) -> [T] {
        subviews.compactMap { $0 as? T } +
        subviews.flatMap { $0.subviews(type: type) }
    }
}
