import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        List {
            ProRowView()
#if DEBUG
            Section {
                Button("Toggle Pro Status") {
                    ProManager.shared.toggleProStatusForTesting()
                }
            }
#endif
            Section {
                AppIconRowView()
                AppearanceRowView()
                WeekStartRowView()
                LanguageRowView()
            }
                  
            Section {
                SoundRowView()
                NotificationsRowView()
                HapticsRowView()
                
            }
            
            Section {
                CloudRowView()
                ArchiveRowView()
                ExportRowView()
            }
            
            AboutSection()
        }
        .navigationTitle("settings")
    }
}
