import SwiftUI

struct SettingsView: View {
//    @State private var selectedSection: SettingsSection

    var body: some View {
        Form {
            PremiumRow()

            Section {
                AppearanceRow()
                AppIconRow()
                LanguageRow()
            }

            Section {
                ArchiveRow()
                SoundsRow()
                NotificationsRow()
            }

            Section {
                RateRow()
                ShareRow()
                PrivacyRow()
                TermsRow()
            } footer: {
                Text("Teymia Habit \(Bundle.main.appVersion)")
            }
        }
        .navigationTitle("Settings")
    }
}

