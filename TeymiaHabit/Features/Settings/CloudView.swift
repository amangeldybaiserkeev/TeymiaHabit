import SwiftUI
import CloudKit

struct CloudRowView: View {
    var body: some View {
        NavigationLink(destination: CloudView()) {
            Label(
                title: { Text("settings_icloud") },
                icon: { Image(systemName: "icloud").iconStyle() }
            )
        }
    }
}

struct CloudView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cloudManager = CloudManager.shared

    var body: some View {
        List {
            Section {
                Image(systemName: "icloud.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section("icloud_sync_status") {
                StatusRow(status: cloudManager.status)
            }

            if case .available = cloudManager.status {
                Section("icloud_manual_sync") {
                    Button {
                        Task { await cloudManager.sync(context: modelContext) }
                    } label: {
                        SyncActionRow(isSyncing: cloudManager.isSyncing)
                    }
                    .disabled(cloudManager.isSyncing)

                    if let lastTime = cloudManager.lastSyncTime {
                        LastSyncRow(date: lastTime)
                    }
                }
            }
            
            Section("icloud_how_sync_works") {
                CloudInfoRow(iconName: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill", title: "icloud_auto", desc: "icloud_auto_desc")
                CloudInfoRow(iconName: "macbook.and.iphone", title: "icloud_cross_device_sync", desc: "icloud_cross_device_sync_desc")
                CloudInfoRow(iconName: "shield.righthalf.filled", title: "icloud_secure", desc: "icloud_secure_desc")
            }
        }
        .navigationTitle("settings_icloud")
        .task { await cloudManager.checkStatus() }
    }
}

// MARK: - Helpers

private struct LastSyncRow: View {
    let date: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("icloud_last_sync")
                    .foregroundStyle(.primary)
                
                Text(formatDate(date))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let time = date.formatted(date: .omitted, time: .shortened)
            return String(localized: "icloud_today_at \(time)")
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

private struct StatusRow: View {
    let status: CloudManager.CloudStatus
    var body: some View {
        HStack {
            Text(status.info).font(.headline)
            Spacer()
            if status == .checking { ProgressView() }
        }
    }
}

private struct SyncActionRow: View {
    let isSyncing: Bool
    var body: some View {
        HStack {
            Text("icloud_force_sync")
                .font(.headline)
                .foregroundStyle(.mainApp.gradient)
            Spacer()
            if isSyncing { ProgressView() }
        }
    }
}

private struct CloudInfoRow: View {
    let iconName: String
    let title: LocalizedStringResource
    let desc: LocalizedStringResource
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.primaryInverse.gradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            Color(.systemGray5), lineWidth: 0.8
                        )
                )
//                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
