import SwiftUI
import SwiftData

struct SoundsRow: View {
    var body: some View {
        NavigationLink {
            SoundsView()
        } label: {
            Label {
                Text("settings_sounds")
            } icon: {
                RowIcon(iconName: "speaker.wave.3.fill", color: .pink, size: 20)
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

        var localizedName: LocalizedStringResource {
            switch self {
            case .completion:   "sound_tab_completion"
            case .notification: "sound_tab_notification"
            }
        }
    }

    var body: some View {
        List {
            Section {
                Picker("", selection: $selectedTab) {
                    ForEach(SoundTab.allCases, id: \.self) { tab in
                        Text(tab.localizedName).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 500)
                .listRowBackground(Color.clear)
            }

            if selectedTab == .completion {
                completionSection
            } else {
                notificationSection
            }
        }
        .navigationTitle("settings_sounds")
    }

    // MARK: - Sections

    private var completionSection: some View {
        let soundManager = appContainer.soundManager
        return Group {
            Section {
                Toggle("enable_sounds", isOn: Binding(
                    get: { soundManager.isSoundEnabled },
                    set: { newValue in
                        withAnimation(.snappy) { soundManager.setSoundEnabled(newValue) }
                    }
                ))
            }

            if soundManager.isSoundEnabled {
                Section {
                    ForEach(CompletionSound.allCases) { sound in
                        SoundSelectionRowView(
                            sound: sound,
                            isSelected: soundManager.selectedSound == sound
                        ) {
                            soundManager.playSound(sound)
                            soundManager.setSelectedSound(sound)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var notificationSection: some View {
        let notificationManager = appContainer.notificationManager
        return Section {
            ForEach(NotificationSound.allCases) { sound in
                SoundSelectionRowView(
                    sound: sound,
                    isSelected: notificationManager.selectedNotificationSound == sound
                ) {
                    appContainer.soundManager.playNotificationPreview(sound)
                    Task {
                        await notificationManager.setSelectedNotificationSound(
                            sound,
                            modelContext: modelContext
                        )
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Shared Row

struct SoundSelectionRowView<T: HabitSoundProtocol>: View {
    let sound: T
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            HStack {
                Text(sound.displayName).foregroundStyle(Color.primary)
                Spacer()
                if isSelected { SelectionCheckmark() }
            }
        }
    }
}
