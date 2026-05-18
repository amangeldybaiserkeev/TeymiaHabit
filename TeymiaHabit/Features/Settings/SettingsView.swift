import SwiftUI

struct SettingsView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isIphone: Bool {
        sizeClass == .compact
    }

    var body: some View {
        NavigationSplitView {
            List {
                PremiumRow()

                Section {
                    AppearanceRow()
                    AppIconRow()
                    LanguageRow()
                }
                .`if`(isIphone) { $0.rowBackground() }

                Section {
                    ArchiveRow()
                    SoundsRow()
                    NotificationsRow()
                }
                .`if`(isIphone) { $0.rowBackground() }

                Section {
                    RateRow()
                    ShareRow()
                    TermsRow()
                    PrivacyRow()
                } footer: {
                    Text("Teymia Habit \(Bundle.main.appVersion)")
                }
                .`if`(isIphone) { $0.rowBackground() }
            }
            .`if`(isIphone) { $0.appBackground(.grouped) }
            .navigationTitle("Settings")
        } detail: {
            Image(systemName: "gear")
                .font(.system(size: 100))
                .foregroundStyle(DS.Colors.secondary.opacity(0.5))
        }
        .ignoresSafeArea(.all)
    }
}

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
