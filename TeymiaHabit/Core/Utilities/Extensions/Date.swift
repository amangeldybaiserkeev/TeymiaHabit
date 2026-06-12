import SwiftUI

extension Calendar {
    static var userPreferred: Calendar {
        var calendar = Self.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
}

extension Date {

    var startOfDay: Date {
        Calendar.userPreferred.startOfDay(for: self)
    }

    var yesterday: Date {
        Calendar.userPreferred.date(byAdding: .day, value: -1, to: self) ?? self
    }

    func formattedAsNavigationTitle() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return String(localized: "Today").capitalized
        }

        if calendar.isDateInYesterday(self) {
            return String(localized: "Yesterday").capitalized
        }

        return self.formatted(.dateTime.day().month(.wide)).capitalized
    }
}

extension Date {
    func nominativeMonthYear() -> String {
        self.formatted(.dateTime.month(.wide).year()).capitalizingFirstLetter()
    }

    func nominativeMonth() -> String {
        self.formatted(.dateTime.month(.wide)).capitalizingFirstLetter()
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst()
    }
}
