import SwiftUI

@MainActor
protocol AppIconManagerProtocol {
    var currentIcon: AppIcon { get }
    func syncWithSystem()
    func setAppIcon(_ icon: AppIcon)
}

#if os(iOS)

@MainActor
@Observable
final class AppIconManager: AppIconManagerProtocol {
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
            if let error {
                print("Failed to change icon: \(error.localizedDescription)")
                Task { @MainActor in
                    self?.syncWithSystem()
                }
            }
        }
    }
}
#else

@MainActor
@Observable
final class AppIconManager: AppIconManagerProtocol {
    private(set) var currentIcon: AppIcon = .main
    
    init() {
        syncWithSystem()
    }
    
    func syncWithSystem() {
        // На macOS всегда main
        currentIcon = .main
    }
    
    func setAppIcon(_ icon: AppIcon) {
        // No-op
        print("App icon change not supported on macOS")
    }
}
#endif
