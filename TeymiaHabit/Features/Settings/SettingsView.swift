import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKeys.isMinimalistIcons) private var isMinimalistIcons = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                PremiumRow()

                ListSection(header: "Appearance") {
                    ThemeRow()
                    AppIconRow()
                    LanguageRow()
                }

                ListSection(header: "Data") {
                    ArchiveRow()
                    SoundsRow()
                    NotificationsRow()
                    MinimalistRow()
                }

                AboutSection()
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.large)
        .background(.groupBackground)
        .environment(\.isMinimalistIcons, isMinimalistIcons)
    }
}
