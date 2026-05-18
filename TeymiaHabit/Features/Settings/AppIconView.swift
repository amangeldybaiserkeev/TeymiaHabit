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
                RowIcon(symbol: .appIcon)
            }
        }
#endif
    }
}

struct AppIconView: View {
    @Environment(AppDependencyContainer.self) private var appContainer

    private static let lockBadgeOffset: CGFloat = 7

    var body: some View {
        Form {
            Section {
                ForEach(AppIcon.allCases) { icon in
                    let isLocked = !appContainer.storeKitService.canUseIcon(icon)
                    let isCurrent = appContainer.iconManager.currentIcon == icon

                    Button {
                        if isLocked {
                            appContainer.showingPaywall = true
                        } else {
                            appContainer.iconManager.setAppIcon(icon)
                        }
                    } label: {
                        HStack(spacing: DS.Spacing.reg) {
                            ZStack(alignment: .topTrailing) {
                                AppIconImage(icon: icon)

                                if isLocked {
                                    PremiumLockBadge()
                                        .offset(x: Self.lockBadgeOffset, y: -Self.lockBadgeOffset)
                                }
                            }

                            Text(icon.title)
                                .foregroundStyle(DS.Colors.primary)

                            Spacer()

                            if isCurrent { SelectionCheckmark() }
                        }
                    }
                }
            }
            .rowBackground()
        }
        .formStyle(.grouped)
        .appBackground(.grouped)
        .navigationTitle("App Icon")
        .animation(DS.Animations.easeInOut, value: appContainer.iconManager.currentIcon)
        .onAppear {
            appContainer.iconManager.syncWithSystem()
        }
    }
}

private struct AppIconImage: View {
    let icon: AppIcon

    private static let size: CGFloat = 48

    var body: some View {
        Image(icon.previewImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(size: Self.size)
    }
}
