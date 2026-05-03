import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            PremiumRow()
            
            Section {
                AppearanceRow()
                AppTintRow()
                AppIconRow()
                ArchiveRow()
                SoundsRow()
                NotificationsRow()
                LanguageRow()
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
        .navigationTitle("settings")
    }
}
