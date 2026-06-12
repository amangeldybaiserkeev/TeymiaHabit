import SwiftUI

struct LanguageRow: View {
    private let option = SettingsOption.language

    var body: some View {
        ExternalLinkRow(
            title: option.title,
            subTitle: currentLanguage,
            icon: SettingsRowIcon(option: option),
            action: openAppSettings
        )
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
