import SwiftUI

@MainActor
@Observable
final class AppIconManager {

    private(set) var currentIcon: AppIcon = .main

    init() {
        syncWithSystem()
    }

    func syncWithSystem() {
        if let iconName = UIApplication.shared.alternateIconName,
           let icon = AppIcon(rawValue: iconName) {
            currentIcon = icon
        } else {
            currentIcon = .main
        }
    }

    func setAppIcon(_ icon: AppIcon) {
        let iconName = icon.name

        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != iconName else { return }

        currentIcon = icon

        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            if error != nil {
                Task { @MainActor in
                    self?.syncWithSystem()
                }
            }
        }
    }
}
