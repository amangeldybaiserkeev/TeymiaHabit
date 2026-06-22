import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    private var UIFields: (name: LocalizedStringKey, icon: String) {
        switch self {
        case .system: ("System", "inset.filled.lefthalf.rectangle.portrait")
        case .light:  ("Light", "sun.horizon")
        case .dark:   ("Dark", "moon.stars")
        }
    }

    var name: LocalizedStringKey { UIFields.name }
    var icon: String { UIFields.icon }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: .none
        case .light:  .light
        case .dark:   .dark
        }
    }
}

struct ThemeRow: View {
    @AppStorage(AppStorageKeys.theme) private var theme: Theme = .system

    var body: some View {
        Picker(selection: $theme) {
            ForEach(Theme.allCases) { mode in
                Text(mode.name).tag(mode)
            }
        } label: {
            Label {
                Text("Appearance")
                    .foregroundStyle(.appPrimary)
            } icon: {
                Image(systemName: theme.icon)
                    .rowIconStyle()
            }
            .contentTransition(.symbolEffect(.replace))
        }
        .pickerStyle(.menu)
        .tint(.secondary)
    }
}
