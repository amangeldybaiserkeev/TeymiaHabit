import Foundation

enum Weekday: Int, CaseIterable, Hashable, Sendable {
    case sunday = 1, monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7

    var shortName: String {
        Calendar.current.shortWeekdaySymbols[self.rawValue - 1]
    }

    var arrayIndex: Int {
        self.rawValue - 1
    }

    var isWeekend: Bool {
        self == .saturday || self == .sunday
    }

    static func from(date: Date) -> Self {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return Self(rawValue: weekdayNumber) ?? .sunday
    }

    static var orderedByUserPreference: [Self] {
        let firstDay = Calendar.current.firstWeekday
        let all = Self.allCases
        let startIndex = firstDay - 1
        let firstPart = all[startIndex...]
        let secondPart = all[..<startIndex]

        return Array(firstPart + secondPart)
    }
}
