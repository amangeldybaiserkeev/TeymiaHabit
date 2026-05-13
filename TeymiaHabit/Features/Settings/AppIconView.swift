import SwiftUI

struct AppIconRow: View {
    var body: some View {
#if os(macOS)
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
#if os(iOS)
struct AppIconView: View {
    @Environment(AppDependencyContainer.self) private var appContainer

    private static let lockBadgeOffset: CGFloat = 7

    var body: some View {
        List {
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
        }
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
    private static let lineWidth: CGFloat = 0.5
    private static let cornerRadius = DS.Radius.sm

    var body: some View {
        Image(icon.previewImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(size: Self.size)
            .clipShape(.rect(cornerRadius: Self.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .stroke(DS.Colors.tertiary, lineWidth: Self.lineWidth)
            }
    }
}
#endif
