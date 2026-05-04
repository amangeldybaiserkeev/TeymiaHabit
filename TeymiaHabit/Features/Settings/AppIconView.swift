import SwiftUI

struct AppIconRow: View {
    var body: some View {
#if !targetEnvironment(macCatalyst)
        EmptyView()
#else
        NavigationLink {
            AppIconView()
        } label: {
            Label {
                Text("settings_app_icon")
            } icon: {
                RowIcon(
                    iconName: "checkmark",
                    weight: .semibold,
                    color: Color.primary,
                    isWhiteBG: true
                )
            }
        }
#endif
    }
}

struct AppIconView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var currentIcon: AppIcon = .main
    
    var body: some View {
        List {
            Section {
                ForEach(AppIcon.allCases) { icon in
                    Button {
                        appContainer.iconManager.setAppIcon(icon)
                        withAnimation(.spring()) { currentIcon = icon }
                    } label: {
                        HStack(spacing: DS.Spacing.reg) {
                            AppIconImage(icon: icon)
                            Text(icon.title).foregroundStyle(Color.primary)
                            Spacer()
                            if currentIcon == icon { SelectionCheckmark() }
                        }
                    }
                }
            }
        }
        .navigationTitle("settings_app_icon")
        .onAppear {
            currentIcon = appContainer.iconManager.currentIcon
        }
    }
}

struct AppIconImage: View {
    let icon: AppIcon
    
    var body: some View {
        Image(icon.previewImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
    }
}
