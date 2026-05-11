import Foundation

extension Calendar {
    static var userPreferred: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
}

extension Date {
    func formattedAsNavigationTitle() -> String {
        if Calendar.current.isDateInToday(self) { return "Today".capitalized }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday".capitalized }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: self).capitalized
    }
}

extension DateFormatter {

    static let nominativeMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    static let nominativeMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()

    static func capitalizedNominativeMonthYear(from date: Date) -> String {
        let dateString = nominativeMonthYear.string(from: date)
        return dateString.capitalizingFirstLetter()
    }

    static func capitalizedNominativeMonth(from date: Date) -> String {
        let dateString = nominativeMonth.string(from: date)
        return dateString.capitalizingFirstLetter()
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        guard let firstChar = self.first else { return self }
        return String(firstChar).uppercased() + self.dropFirst()
    }
}
