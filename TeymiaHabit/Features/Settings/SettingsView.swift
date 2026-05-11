import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
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
                OnboardingRow()
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

