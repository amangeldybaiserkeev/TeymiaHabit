import SwiftUI

struct BlurView: UIViewRepresentable {
    public var blurRadius: CGFloat

    public init(blurRadius: CGFloat = 20) {
        self.blurRadius = blurRadius
    }

    public func makeUIView(context: Context) -> BlurUIView {
        BlurUIView(blurRadius: blurRadius)
    }

    public func updateUIView(_ uiView: BlurUIView, context: Context) {}
}

class BlurUIView: UIVisualEffectView {

    init(blurRadius: CGFloat) {
        super.init(effect: UIBlurEffect(style: .regular))

        for subview in subviews where subview.description.contains("VisualEffectSubview") {
            subview.isHidden = true
        }

        if let backdropLayer = layer.sublayers?.first {
            backdropLayer.backgroundColor = nil
            backdropLayer.isOpaque = false

            if let filters = backdropLayer.filters {
                backdropLayer.filters = filters.filter { "\($0)" == "gaussianBlur" }
            }

            backdropLayer.setValue(blurRadius as NSNumber, forKeyPath: "filters.gaussianBlur.inputRadius")
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {}
}
