//
//  HabitSubtask.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 28.02.26.
//

// File: TeymiaHabit/Models/HabitSubtask.swift
import Foundation
import SwiftData

@Model
final class HabitSubtask {
    /// Eindeutige ID für die Identifizierung in Listen
    var uuid: UUID = UUID()
    
    /// Der Name der Unteraufgabe
    var title: String = ""
    
    /// Die Sortierreihenfolge innerhalb der Gewohnheit
    var displayOrder: Int = 0
    
    /// Optionale Verknüpfung zur übergeordneten Gewohnheit
    var habit: Habit?
    
    init(title: String = "", displayOrder: Int = 0, habit: Habit? = nil) {
        self.uuid = UUID()
        self.title = title
        self.displayOrder = displayOrder
        self.habit = habit
    }
}
