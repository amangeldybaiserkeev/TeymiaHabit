import SwiftUI

struct AppearanceRowView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        NavigationLink(destination: AppearanceView()) {
            HStack {
                Label(
                    title: { Text("settings_appearance") },
                    icon: { Image(systemName: "moon.stars").iconStyle() }
                )
                Spacer()
                Text(themeMode.localizedName).foregroundStyle(Color.secondary)
            }
        }
    }
}

struct AppearanceView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        List {
            Section {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button {
                        themeMode = mode
                        HapticManager.shared.playSelection()
                    } label: {
                        HStack {
                            Label(
                                title: { Text(mode.localizedName).foregroundStyle(Color.primary) },
                                icon: {
                                    Image(systemName: mode.iconName)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.primary.gradient)
                                }
                            )
                            Spacer()
                            if themeMode == mode { SelectionCheckmark() }
                        }
                    }
                }
            }
            .animation(.snappy, value: themeMode)
        }
        .navigationTitle("settings_appearance")
    }
}
