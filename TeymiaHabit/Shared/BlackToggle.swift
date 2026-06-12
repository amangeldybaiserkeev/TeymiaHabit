import SwiftUI
import UIKit

struct BlackToggle: UIViewRepresentable {
    @Binding var isOn: Bool

    func makeUIView(context: Context) -> UISwitch {
        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = .white
        uiSwitch.backgroundColor = .black
        uiSwitch.thumbTintColor = .black
        uiSwitch.subviews.first?.subviews.first?.backgroundColor = .black
        uiSwitch.perform(#selector(setter: UIView.backgroundColor), with: UIColor.black)
        uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2
        uiSwitch.clipsToBounds = true

        uiSwitch.addTarget(context.coordinator,
                          action: #selector(Coordinator.onValueChanged),
                          for: .valueChanged)

        DispatchQueue.main.async {
            uiSwitch.thumbTintColor = .black
            uiSwitch.subviews.first?.subviews.first?.backgroundColor = UIColor(named: "ToggleBackground")
        }

        return uiSwitch
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        if uiView.isOn != isOn {
            uiView.setOn(isOn, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: BlackToggle
        init(_ parent: BlackToggle) { self.parent = parent }
        @objc func onValueChanged(_ sender: UISwitch) {
            parent.isOn = sender.isOn
        }
    }
}
