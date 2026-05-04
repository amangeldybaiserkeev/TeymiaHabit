import SwiftUI

struct LanguageRow: View {
    var body: some View {
#if !targetEnvironment(macCatalyst)
        EmptyView()
#else
        Button {
            openAppSettings()
        } label: {
            HStack {
                Label {
                    Text("settings_language")
                        .foregroundStyle(DS.Colors.primary)
                } icon: {
                    RowIcon(iconName: "globe", color: .blue)
                }
                Spacer()
                Text(currentLanguage)
                    .foregroundStyle(DS.Colors.secondary)

            }
        }
#endif
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private var currentLanguage: String {
        let languageCode = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale.current.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode
    }
}

