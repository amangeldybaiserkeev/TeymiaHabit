import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var date: Date = Date()
    var value: Int = 0
    var habit: Habit?

    init(date: Date = Date(), value: Int = 0, habit: Habit? = nil) {
        self.date = date
        self.value = value
        self.habit = habit
    }

    var formattedTime: String {
        value.formattedAsTime()
    }

    var hours: Int {
        value / 3600
    }

    var minutes: Int {
        (value % 3600) / 60
    }

    var seconds: Int {
        value % 60
    }

    func addMinutes(_ minutes: Int) {
        value += minutes * 60
    }

    static func secondsFrom(hours: Int, minutes: Int, seconds: Int = 0) -> Int {
        (hours * 3600) + (minutes * 60) + seconds
    }
}
