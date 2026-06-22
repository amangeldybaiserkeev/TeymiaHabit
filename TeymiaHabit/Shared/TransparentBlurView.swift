import SwiftUI

struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomBlurView {
        let view = CustomBlurView(effect: .init(style: .systemUltraThinMaterial))
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: CustomBlurView, context: Context) {  }
}

class CustomBlurView: UIVisualEffectView {
    init(effect: UIBlurEffect) {
        super.init(effect: effect)
        setup()
    }

    func setup() {
        removeFilters()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            DispatchQueue.main.async {
                self.removeFilters()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func removeFilters() {
        if let filterLayer = layer.sublayers?.first {
            filterLayer.filters = []
        }
    }
}
