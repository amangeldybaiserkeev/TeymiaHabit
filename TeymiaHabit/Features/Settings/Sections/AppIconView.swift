import SwiftUI

struct AppIconRow: View {

    var body: some View {
        NavigationLink {
            AppIconView()
        } label: {
            SettingsRow(item: .appIcon)
        }
    }
}

struct AppIconView: View {
    @State private var appIconManager = AppIconManager()
    @State private var showingPaywall = false
    @Environment(StoreKitService.self) private var storeKitService

    private static let lockBadgeOffset: CGFloat = 7

    var body: some View {
        List {
            ForEach(AppIcon.allCases) { icon in
                let isLocked = !storeKitService.canUseIcon(icon)
                let isCurrent = appIconManager.currentIcon == icon

                Button {
                    if isLocked {
                        showingPaywall = true
                    } else {
                        appIconManager.setAppIcon(icon)
                    }
                } label: {
                    HStack(spacing: Spacing.reg) {
                        ZStack(alignment: .topTrailing) {
                            AppIconImage(icon: icon)

                            if isLocked {
                                PremiumLockBadge()
                                    .offset(x: Self.lockBadgeOffset, y: -Self.lockBadgeOffset)
                            }
                        }

                        Text(icon.title)
                            .foregroundStyle(Color.primary)

                        Spacer()

                        if isCurrent { SelectionCheckmark() }
                    }
                }
            }
        }
        .navigationTitle("App Icon")
        .animation( Animations.easeInOut, value: appIconManager.currentIcon)
        .onAppear { appIconManager.syncWithSystem() }
    }
}

private struct AppIconImage: View {
    let icon: AppIcon

    private let size: CGFloat = 48

    var body: some View {
        Image(icon.previewImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(size: size)
    }
}
