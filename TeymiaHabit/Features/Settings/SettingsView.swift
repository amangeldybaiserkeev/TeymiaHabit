import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppDependencyContainer.self) private var appContainer
    
    var body: some View {
        List {
            ProRowView()
            
            Section {
#if !os(macOS)
                AppIconRowView()
#endif
                AppearanceRowView()
                LanguageRowView()
            }
            
            Section {
                SoundRowView()
                NotificationsRowView()
                HapticsRowView()
                
            }
            
            Section {
                ArchiveRowView()
            }
            
            AboutSection()
            
#if DEBUG
            Section {
                Button("Toggle Pro Status") {
                    appContainer.proManager.toggleProStatusForTesting()
                }
            }
#endif
        }
        .navigationTitle("settings")
    }
}
