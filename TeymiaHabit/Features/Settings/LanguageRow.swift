import SwiftUI

struct LanguageRow: View {
    var body: some View {
#if os(macOS)
        EmptyView()
#else
        Button {
            openAppSettings()
        } label: {
            HStack {
                Label {
                    Text("Language")
                        .foregroundStyle(DS.Colors.primary)
                } icon: {
                    RowIcon(iconName: "globe.americas")
                }
                Spacer()
                Text(currentLanguage)
                    .foregroundStyle(DS.Colors.secondary)

            }
        }
#endif
    }

    #if os(iOS)
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    #endif

    private var currentLanguage: String {
        let languageCode = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale.current.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode
    }
}
