import SwiftUI

struct MinimalistIconsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isMinimalistIcons: Bool {
        get { self[MinimalistIconsKey.self] }
        set { self[MinimalistIconsKey.self] = newValue }
    }
}
