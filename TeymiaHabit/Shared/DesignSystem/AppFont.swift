import SwiftUI

enum AppFont {

    private static let titleSize: CGFloat = 18
    private static let largeTitleSize: CGFloat = 34

    static func configureAppearance() {
        configureNavigationBar()
        configureTabBar()
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: titleSize, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.rounded(ofSize: largeTitleSize, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: Weight = .regular) -> UIFont {
        let descriptor = Self.systemFont(ofSize: size, weight: weight).fontDescriptor
        return UIFont(descriptor: descriptor.withDesign(.rounded) ?? descriptor, size: size)
    }
}
