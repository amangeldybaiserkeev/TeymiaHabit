import SwiftUI

enum NewHabitItem {
    case name, icon, goal, startDate, reminders

    private var fields: (title: LocalizedStringKey, icon: String) {
        switch self {
        case .name: ("Habit Name", "applepencil.hover")
        case .icon: ("Icon", "app.badge.checkmark")
        case .goal: ("Goal", "dot.scope")
        case .startDate: ("Start Date", "calendar.badge")
        case .reminders: ("Reminders", "bell.badge")
        }
    }

    var title: LocalizedStringKey { fields.title }
    var icon: String { fields.icon }

    var needsInvertedIcon: Bool {
        switch self {
        case .name, .icon, .startDate, .reminders: return true
        default: return false
        }
    }
}

struct NewHabitRow: View {
    let item: NewHabitItem

    var body: some View {
        Label {
            Text(item.title)
                .foregroundStyle(.appPrimary)
        } icon: {
            Image(systemName: item.icon)
                .rowIconStyle(isInverted: item.needsInvertedIcon)
        }
    }
}
