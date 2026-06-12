import Foundation

enum HabitType: Int, Codable, CaseIterable {
    case count
    case time

    var name: String {
        switch self {
        case .count: "Count"
        case .time: "Time"
        }
    }

    var defaultGoal: Int {
        switch self {
        case .count: 1
        case .time: 1800 /// 30 minutes
        }
    }
}
