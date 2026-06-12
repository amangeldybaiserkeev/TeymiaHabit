import Foundation

extension Int {
    func formattedAsTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    func formattedAsChartDuration() -> String {
            let hours = self / 3600
            let minutes = (self % 3600) / 60

            if hours > 0 {
                return String(format: "%d:%02d", hours, minutes)
            } else {
                return String(format: "0:%02d", minutes)
            }
        }

    func formattedAsLocalizedDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(self)) ?? "\(self)s"
    }
}
