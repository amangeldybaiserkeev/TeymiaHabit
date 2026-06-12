import SwiftUI

struct ThemeRow: View {
    @AppStorage(AppStorageKeys.theme) private var theme: Theme = .system
    @Environment(\.dismiss) private var dismiss

    private var option: SettingsOption {
        SettingsOption.appearance(theme)
    }

    var body: some View {
        PopoverView {
            ListRow {
                SettingsRowIcon(option: option)
                    .contentTransition(.symbolEffect(.replace))

                Text(option.title)
                    .font(.body)
                    .foregroundStyle(.appPrimary)

                Spacer()

                HStack(spacing: Spacing.xs) {
                    Text(theme.name)
                        .foregroundStyle(.appSecondary)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.iconSecondary)
                }
            }
            .contentShape(.rect)
        } content: {
            VStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.snappy) {
                            theme = mode
                        }
                        dismiss()
                    } label: {
                        HStack(spacing: Spacing.reg) {
                            Image(systemName: mode.iconName)
                                .foregroundStyle(theme == mode ? .appPrimary : .appSecondary)

                            Text(mode.name)
                                .foregroundStyle(theme == mode ? .appPrimary : .appSecondary)

                            Spacer()

                            if theme == mode {
                                Image(systemName: "checkmark")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.main)
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.reg)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)

                    if mode != Theme.allCases.last {
                        Divider()
                            .padding(.horizontal, Spacing.reg)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
            .frame(width: 220)
            .presentationDetents([.height(160)])
        }
    }
}

private extension Theme {
    var iconName: String {
        switch self {
        case .system: return "iphone"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }
}
