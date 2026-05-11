import SwiftUI

// MARK: - Rate
struct RateRow: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        Button {
            openURL(AppConfig.rateAppURL)
        } label: {
            AboutLabel(title: "Rate", icon: "star")
        }
    }
}

// MARK: - Share
struct ShareRow: View {
    var body: some View {
        ShareLink(item: AppConfig.appStoreURL) {
            AboutLabel(title: "Share", icon: "square.and.arrow.up")
        }
    }
}

// MARK: - Privacy Policy
struct PrivacyRow: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        Button {
            openURL(AppConfig.privacyPolicyURL, prefersInApp: true)
        } label: {
            AboutLabel(title: "Privacy Policy", icon: "lock")
        }
    }
}

// MARK: - Terms of Service
struct TermsRow: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        Button {
            openURL(AppConfig.termsOfServiceURL, prefersInApp: true)
        } label: {
            AboutLabel(title: "Terms of Service", icon: "doc.text")
        }
    }
}

// MARK: - Private Helper
private struct AboutLabel: View {
    let title: LocalizedStringKey
    let icon: String

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(DS.Colors.primary)
        } icon: {
            RowIcon(iconName: icon)
        }
    }
}

enum AppConfig {
    static let appStoreURL = createURL("https://apps.apple.com/app/id6746747903")
    static let rateAppURL = createURL("https://apps.apple.com/app/id6746747903?action=write-review")
    static let privacyPolicyURL = createURL("https://www.notion.so/Privacy-Policy-1ffd5178e65a80d4b255fd5491fba4a8")
    static let termsOfServiceURL = createURL("https://www.notion.so/Terms-of-Service-204d5178e65a80b89993e555ffd3511f")

    private static func createURL(_ string: String) -> URL {
        URL(string: string) ?? URL(fileURLWithPath: "")
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.1"
    }
}

