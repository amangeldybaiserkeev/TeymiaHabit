import SwiftUI
import SwiftData

struct SoundsRow: View {
    var body: some View {
        NavigationLink {
            SoundsView()
        } label: {
            Label {
                Text("Sounds")
            } icon: {
                RowIcon(symbol: .sounds)
            }
        }
    }
}

struct SoundsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppDependencyContainer.self) private var appContainer

    @State private var selectedTab: SoundTab = .completion

    enum SoundTab: String, CaseIterable {
        case completion, notification

        var localizedName: LocalizedStringKey {
            switch self {
            case .completion:   "Completion"
            case .notification: "Notifications"
            }
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()

                    Picker("", selection: $selectedTab) {
                        ForEach(SoundTab.allCases, id: \.self) { tab in
                            Text(tab.localizedName).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)

                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            if selectedTab == .completion {
                completionSection
            } else {
                notificationSection
            }
        }
        .navigationTitle("Sounds")
        .appBackground(.grouped)
    }

    // MARK: - Sections

    private var completionSection: some View {
        let soundManager = appContainer.soundManager
        let storeKit = appContainer.storeKitService

        return Group {
            Section {
                Toggle("Enable Sounds", isOn: Binding(
                    get: { soundManager.isSoundEnabled },
                    set: { newValue in
                        withAnimation(.snappy) { soundManager.setSoundEnabled(newValue) }
                    }
                ))
                .tint(nil)
            }
            .rowBackground()

            if soundManager.isSoundEnabled {
                Section {
                    ForEach(CompletionSound.allCases) { sound in
                        let isLocked = !storeKit.canUseSounds(sound)

                        SoundSelectionRowView(
                            sound: sound,
                            isSelected: soundManager.selectedSound == sound,
                            isLocked: isLocked,
                            onPlay: {
                                soundManager.playSound(sound)
                            },
                            onSelect: {
                                if !isLocked {
                                    soundManager.playSound(sound)
                                    soundManager.setSelectedSound(sound)
                                } else {
                                    soundManager.playSound(sound)
                                    appContainer.showingPaywall = true
                                }
                            }
                        )
                    }
                }
                .rowBackground()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var notificationSection: some View {
        let notificationManager = appContainer.notificationManager
        let storeKit = appContainer.storeKitService

        return Section {
            ForEach(NotificationSound.allCases) { sound in
                let isLocked = !storeKit.canUseSounds(sound)

                SoundSelectionRowView(
                    sound: sound,
                    isSelected: notificationManager.selectedNotificationSound == sound,
                    isLocked: isLocked,
                    onPlay: {
                        appContainer.soundManager.playNotificationPreview(sound)
                    },
                    onSelect: {
                        if !isLocked {
                            appContainer.soundManager.playNotificationPreview(sound)
                            Task {
                                await notificationManager.setSelectedNotificationSound(
                                    sound,
                                    modelContext: modelContext
                                )
                            }
                        } else {
                            appContainer.soundManager.playNotificationPreview(sound)
                            appContainer.showingPaywall = true
                        }
                    }
                )
            }
        }
        .rowBackground()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Shared Row

struct SoundSelectionRowView<T: HabitSoundProtocol>: View {
    let sound: T
    let isSelected: Bool
    let isLocked: Bool
    let onPlay: () -> Void
    let onSelect: () -> Void

    @State private var animateTrigger: Int = 0

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Button {
                onPlay()
                animateTrigger += 1
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(DS.Colors.primary)
                    .symbolEffect(.variableColor.iterative.nonReversing, value: animateTrigger)
                    .frame(size: DS.IconSize.md)
                    .background(DS.Colors.primary.opacity(0.1), in: .circle)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)

            HStack {
                Text(sound.displayName)
                    .foregroundStyle(DS.Colors.primary)
                Spacer()
                if isLocked { PremiumLockCapsule() }
                if isSelected { SelectionCheckmark() }
            }
            .contentShape(.rect)
            .onTapGesture {
                animateTrigger += 1
                onSelect()
            }
        }
    }
}
