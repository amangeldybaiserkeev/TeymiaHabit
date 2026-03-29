import Foundation

enum TaskScope: String, Codable, CaseIterable {
    case inbox
    case today
    case upcoming
    case completed
}

extension TaskScope: Identifiable {
    var id: String { self.rawValue }
}
