import Foundation

struct GoalConfiguration {
    var countText: String = "1"
    var hours: Int = 0
    var minutes: Int = 30
    var parsedCount: Int? {
        guard let value = Int(countText), value > 0 else { return nil }
        return value
    }
}

extension GoalConfiguration {
    var dateRepresentation: Date {
        get {
            Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            hours = components.hour ?? 0
            minutes = components.minute ?? 0
        }
    }
}
