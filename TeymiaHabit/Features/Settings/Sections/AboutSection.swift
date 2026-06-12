import SwiftUI

struct AboutSection: View {
    @Environment(\.openURL) private var openURL

    private let rateOption = SettingsOption.rate
    private let shareOption = SettingsOption.share
    private let termsOption = SettingsOption.terms
    private let privacyOption = SettingsOption.privacy

    var body: some View {
        ListSection(
            header: "About",
            footer: "Teymia Habit \(Bundle.main.appVersion)"
        ) {
            shareButton
            rateButton
            termsButton
            privacyButton
        }
    }

    private var shareButton: some View {
        ShareLink(item: AppConfig.appStoreURL) {
            ListRow {
                SettingsRowIcon(option: shareOption)

                Text(shareOption.title)
                    .foregroundStyle(.appPrimary)

                Spacer()
            }
        }
        .hasIcon(true)
    }

    private var rateButton: some View {
        ExternalLinkRow(
            title: rateOption.title,
            icon: SettingsRowIcon(option: rateOption),
        ) {
            openURL(AppConfig.rateURL)
        }
    }

    private var termsButton: some View {
        ExternalLinkRow(
            title: termsOption.title,
            icon: SettingsRowIcon(option: termsOption),
        ) {
            openURL(AppConfig.termsURL)
        }
    }

    private var privacyButton: some View {
        ExternalLinkRow(
            title: privacyOption.title,
            icon: SettingsRowIcon(option: privacyOption),
        ) {
            openURL(AppConfig.privacyURL)
        }
    }
}

private enum AppConfig {
    static let appStoreURL = createURL("https://apps.apple.com/app/id6746747903")
    static let rateURL = createURL("https://apps.apple.com/app/id6746747903?action=write-review")
    static let privacyURL = createURL("https://www.notion.so/Privacy-Policy-1ffd5178e65a80d4b255fd5491fba4a8")
    static let termsURL = createURL("https://www.notion.so/Terms-of-Service-204d5178e65a80b89993e555ffd3511f")

    private static func createURL(_ string: String) -> URL {
        URL(string: string) ?? URL(fileURLWithPath: "")
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.1"
    }
}
