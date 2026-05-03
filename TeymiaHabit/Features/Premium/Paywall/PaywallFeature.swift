import SwiftUI

struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: LocalizedStringResource
    var description: LocalizedStringResource? = nil
    
    static let allFeatures: [Self] = [
        Self(
            icon: "infinity",
            title: "paywall_unlimited_habits_title",
            description: "paywall_unlimited_habits_description"
        ),
        Self(
            icon: "bell",
            title: "paywall_multiple_reminders_title",
            description: "paywall_multiple_reminders_description"
        ),
        Self(
            icon: "speaker.wave.2",
            title: "paywall_sounds_title",
            description: "paywall_sounds_description"
        ),
        Self(
            icon: "chart.bar",
            title: "paywall_statistics_title",
            description: "paywall_statistics_description"
        ),
        Self(
            icon: "app.specular",
            title: "paywall_app_icons_title"
        ),
        Self(
            icon: "sparkles",
            title: "paywall_access_new_features_title",
            description: "paywall_access_new_features_description"
        )
    ]
}
