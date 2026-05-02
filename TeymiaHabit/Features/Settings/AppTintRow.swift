import SwiftUI

struct AppTintRow: View {
    @AppStorage("appTintColor") private var appTintColor: Int = AppTintColor.blue.rawValue

    private var selectedTint: AppTintColor {
        AppTintColor(rawValue: appTintColor) ?? .blue
    }

    var body: some View {
        NavigationLink(destination: AppTintView()) {
            Label {
                HStack {
                    Text("settings_app_tint")
                    Spacer()
                    Circle()
                        .fill(selectedTint.color)
                        .frame(width: 20, height: 20)
                }
            } icon: {
                RowIcon(iconName: "paintpalette.fill", color: selectedTint.color)
            }
        }
    }
}

// MARK: - Tint Picker View

struct AppTintView: View {
    @AppStorage("appTintColor") private var appTintColor: Int = AppTintColor.blue.rawValue

    private var selectedTint: AppTintColor {
        AppTintColor(rawValue: appTintColor) ?? .blue
    }

    var body: some View {
        Form {
            Section {
                ForEach(AppTintColor.allCases, id: \.rawValue) { tint in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            appTintColor = tint.rawValue
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(tint.color)
                                .frame(width: 28, height: 28)

                            Text(tint.localizedName)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            if selectedTint == tint {
                                SelectionCheckmark()
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("settings_app_tint")
        .sensoryFeedback(.selection, trigger: appTintColor)
    }
}
