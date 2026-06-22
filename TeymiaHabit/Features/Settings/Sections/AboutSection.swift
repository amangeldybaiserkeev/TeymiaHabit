import SwiftUI

struct AboutSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            shareButton
            rateButton
            termsButton
            privacyButton
        } footer: {
            Text("Teymia Habit \(Bundle.main.appVersion)")
        }
    }

    private var shareButton: some View {
        ShareLink(item: AppConfig.appStoreURL) {
            SettingsRow(item: .share)
        }
    }

    private var rateButton: some View {
        Button {
            openURL(AppConfig.rateURL, prefersInApp: true)
        } label: {
            SettingsRow(item: .rate)
        }
    }

    private var termsButton: some View {
        Button {
            openURL(AppConfig.termsURL, prefersInApp: true)
        } label: {
            SettingsRow(item: .terms)
        }
    }

    private var privacyButton: some View {
        Button {
            openURL(AppConfig.privacyURL, prefersInApp: true)
        } label: {
            SettingsRow(item: .privacy)
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
