import SwiftUI

struct MinimalistRow: View {
    @AppStorage(AppStorageKeys.isMinimalistIcons) private var isMinimalistIcons = false

    private let option = SettingsOption.minimalist

    var body: some View {
        ActionRow(
            title: option.title,
            icon: SettingsRowIcon(option: option),
            action: {
                withAnimation(.snappy) {
                    isMinimalistIcons.toggle()
                }
            }
        ) {
            Toggle("", isOn: $isMinimalistIcons)
                .labelsHidden()
                .tint(.toggle)
        }
    }
}
