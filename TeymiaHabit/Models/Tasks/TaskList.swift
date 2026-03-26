import SwiftUI
import SwiftData

@Model
final class TaskList {
    var title: String
    var iconName: String
    var iconColor: HabitIconColor
    var group: TaskGroup?
    
    @Relationship(deleteRule: .cascade, inverse: \TodoTask.list)
    var tasks: [TodoTask] = []
    
    init(title: String, iconName: String = "list.bullet", color: HabitIconColor = .gray) {
        self.title = title
        self.iconName = iconName
        self.iconColor = color
    }

    var color: Color {
        iconColor.color
    }
}
