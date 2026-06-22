import SwiftUI

struct SettingsView: View {

    var body: some View {
        List {
            Section {
                PremiumRow()
            }
            .listRowBackground(Color.clear)

            Section {
                ThemeRow()
                AppIconRow()
                LanguageRow()
            }

            Section {
                ArchiveRow()
                SoundsRow()
                NotificationsRow()
            }

            AboutSection()
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(.groupBackground)
    }
}
