import SwiftUI

struct AppTintRow: View {
    @AppStorage("appTintColor") private var appTintColor: String = AppTintColor.blue.rawValue
    
    private var currentColor: Color {
        AppTintColor(rawValue: appTintColor)?.color ?? .primary
    }
    
    var body: some View {
        NavigationLink {
            AppTintView()
        } label: {
            Label {
                Text("settings_app_tint")
            } icon: {
                RowIcon(iconName: "paintbrush.pointed.fill", color: currentColor)
            }
        }
    }
}

struct AppTintView: View {
    @AppStorage("appTintColor") private var appTintColor: String = AppTintColor.blue.rawValue
    
    var body: some View {
        Form {
            ForEach(AppTintColor.allCases) { tint in
                Button {
                    withAnimation(DS.Animations.easeInOut) {
                        appTintColor = tint.rawValue
                    }
                } label: {
                    HStack {
                        Label {
                            Text(tint.localizedName)
                                .foregroundStyle(Color.primary)
                        } icon: {
                            Circle()
                                .fill(tint.color)
                                .frame(size: DS.IconSize.md)
                        }

                        Spacer()
                        
                        if tint.rawValue == appTintColor {
                            SelectionCheckmark()
                        }
                    }
                }
            }
        }
        .navigationTitle("settings_app_tint")
        .sensoryFeedback(.selection, trigger: appTintColor)
    }
}
