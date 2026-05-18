import SwiftUI

struct MediumSheetEnforcer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        enforceMediumSheet()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func enforceMediumSheet(retry: Int = 0) {
        let delay = 0.1 + Double(retry) * 0.05

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard let sheet = findCurrentSheet() else {
                if retry < 10 {
                    enforceMediumSheet(retry: retry + 1)
                }
                return
            }

            if sheet.selectedDetentIdentifier != .medium {
                sheet.animateChanges {
                    sheet.detents = [.medium()]
                    sheet.selectedDetentIdentifier = .medium
                }
            }
        }
    }

    private func findCurrentSheet() -> UISheetPresentationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return nil
        }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        return topVC.sheetPresentationController
    }
}
