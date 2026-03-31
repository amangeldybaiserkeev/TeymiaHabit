import SwiftUI

@MainActor
@Observable
final class AppIconManager {
    private let proManager: ProManager
    var currentIcon: AppIcon
    
    init(proManager: ProManager) {
        self.proManager = proManager
        
        let iconName = UIApplication.shared.alternateIconName
        if let iconName, let icon = AppIcon(rawValue: iconName) {
            self.currentIcon = icon
        } else {
            self.currentIcon = .main
        }
    }
    
    func setAppIcon(_ icon: AppIcon) {
        guard !icon.requiresPro || proManager.isPro else { return }
        let iconName: String? = (icon == .main) ? nil : icon.rawValue
        guard UIApplication.shared.alternateIconName != iconName else { return }
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if error == nil {
                Task { @MainActor in
                    self.currentIcon = icon
                }
            }
        }
    }
}
