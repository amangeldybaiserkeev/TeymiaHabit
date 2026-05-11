import SwiftUI

struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: LocalizedStringKey
    var description: LocalizedStringKey? = nil

    static let allFeatures: [Self] = [
        Self(
            icon: "infinity",
            title: "Unlimited Habits",
            description: "Create as many habits as you need"
        ),
        Self(
            icon: "bell",
            title: "Multiple Reminders",
            description: "Set unlimited habit reminders"
        ),
        Self(
            icon: "speaker.wave.2",
            title: "Premium Sounds",
            description: "Effects when you need to complete habit"
        ),
        Self(
            icon: "chart.bar",
            title: "Detailed Statistics",
            description: "Advanced calendar view and progress charts"
        ),
        Self(
            icon: "app.specular",
            title: "Premium App Icons"
        ),
        Self(
            icon: "sparkles",
            title: "Early Access",
            description: "Get access to new features"
        )
    ]
}

