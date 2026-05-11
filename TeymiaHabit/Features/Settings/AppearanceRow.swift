import SwiftUI

struct AppearanceRow: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system

    var body: some View {
        Picker(selection: $themeMode) {
            ForEach(ThemeMode.allCases, id: \.self) { mode in
                Text(mode.localizedName).tag(mode)
            }
        } label: {
            Label(
                title: { Text("Appearance") },
                icon: { RowIcon(iconName: themeMode.iconName) }
            )
            .contentTransition(.symbolEffect(.replace))
        }
        .pickerStyle(.menu)
        .tint(.secondary)
    }
}

