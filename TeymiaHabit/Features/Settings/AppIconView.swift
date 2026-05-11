import SwiftUI

struct AppIconRow: View {
    var body: some View {
#if targetEnvironment(macCatalyst)
        EmptyView()
#else
        NavigationLink {
            AppIconView()
        } label: {
            Label {
                Text("App Icon")
            } icon: {
                RowIcon(iconName: "checkmark.app")
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
                    let isLocked = !appContainer.storeKitService.canUseIcon(icon)

                    Button {
                        if !isLocked {
                            appContainer.iconManager.setAppIcon(icon)
                            withAnimation(.spring()) { currentIcon = icon }
                        } else {
                            appContainer.showingPaywall = true
                        }
                    } label: {
                        HStack(spacing: DS.Spacing.reg) {
                            ZStack(alignment: .topTrailing) {
                                AppIconImage(icon: icon)

                                if isLocked {
                                    PremiumLockBadge()
                                        .offset(x: 6, y: -6)
                                }
                            }

                            Text(icon.title).foregroundStyle(Color.primary)

                            Spacer()

                            if currentIcon == icon {
                                SelectionCheckmark()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("App Icon")
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

