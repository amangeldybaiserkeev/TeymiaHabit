import SwiftUI

enum RowIcon {
    case habitGoal, habitIcon, habitName, habitStartDate, habitReminders

    var iconName: String {
        switch self {
        case .habitGoal: "trophy"
        case .habitIcon: "app.specular"
        case .habitName: "pencil"
        case .habitStartDate: "calendar"
        case .habitReminders: "bell.badge"
        }
    }
}

struct RowIconView: View {
    let symbol: RowIcon

    var body: some View {
        Image(systemName: symbol.iconName)
            .font(.callout)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
    }
}
