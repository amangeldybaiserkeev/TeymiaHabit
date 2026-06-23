import SwiftUI

struct HabitTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: HabitIconColor
    let type: HabitType
    let goal: Int
    let source: HabitSource
    var healthKitMetric: HealthKitMetric?
    var videoName: String?

    static let allTemplates: [Self] = [
        Self(
            name: "Read a book",
            icon: "book.fill",
            color: .yellowOrange,
            type: .time,
            goal: 600,
            source: .manual,
            videoName: "template-reading"
        ),
        Self(
            name: "Meditate",
            icon: "person.meditation.fill",
            color: .softLavender,
            type: .time,
            goal: 600,
            source: .manual
        ),
        Self(
            name: "Smile",
            icon: "face.smile",
            color: .yellow,
            type: .count,
            goal: 5,
            source: .manual,
            videoName: "template-smile"
        ),
        Self(
            name: "Walking",
            icon: "barefoot",
            color: .brown,
            type: .count,
            goal: 1,
            source: .manual,
            videoName: "template-walking"
        ),
        Self(
            name: "Play an instrument",
            icon: "piano.keyboard",
            color: .primary,
            type: .time,
            goal: 600,
            source: .manual,
            videoName: "template-piano"
        ),

        // Apple Health
        Self(
            name: "Sleep",
            icon: "bed.fill",
            color: .blue,
            type: .time,
            goal: 8,
            source: .healthKit,
            healthKitMetric: .sleep
        ),
        Self(
            name: "Steps",
            icon: "footprint.fill",
            color: .brown,
            type: .count,
            goal: 10_000,
            source: .healthKit,
            healthKitMetric: .steps
        )
    ]
}
