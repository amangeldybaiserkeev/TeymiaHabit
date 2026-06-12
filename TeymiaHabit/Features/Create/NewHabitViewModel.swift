import SwiftUI
import SwiftData
import HealthKit

@Observable
final class NewHabitViewModel {
    var source: HabitSource = .manual
    var healthKitMetric: HealthKitMetric?
    var title = ""
    var selectedType: HabitType = .count
    var goalCountText = ""
    var goalHours = 0
    var minutes = 0
    var activeDays: [Bool] = Array(repeating: true, count: 7)
    var startDate = Date()
    var isReminderEnabled = false
    var reminderTimes: [Date] = [Date()]
    var selectedIcon = "book.fill"
    var selectedIconColor: HabitIconColor = .primary
    var showingPaywall = false
    var isRequestingHealthAuth = false

    init() {}

    func setup(habit: Habit?, template: HabitTemplate?) {
        if let habit {
            loadHabit(habit)
        } else if let template {
            loadTemplate(template)
        }
    }

    var effectiveGoal: Int {
        switch selectedType {
        case .count: return Int(goalCountText) ?? 1
        case .time:  return (goalHours * 3600) + (minutes * 60)
        }
    }

    var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let hasGoal: Bool = switch selectedType {
        case .count: (Int(goalCountText) ?? 0) > 0
        case .time:  goalHours > 0 || minutes > 0
        }
        return hasTitle && hasGoal
    }

    private func loadHabit(_ habit: Habit) {
        title = habit.title
        selectedType = habit.type
        startDate = habit.startDate
        selectedIcon = habit.iconName
        selectedIconColor = habit.iconColor
        activeDays = habit.activeDays
        isReminderEnabled = habit.reminderTimes?.isEmpty == false
        reminderTimes = habit.reminderTimes ?? [Date()]
        source = habit.source
        healthKitMetric = habit.healthKitMetric

        if habit.type == .count {
            goalCountText = String(habit.goal)
        } else {
            goalHours = habit.goal / 3600
            minutes = (habit.goal % 3600) / 60
        }
    }

    private func loadTemplate(_ template: HabitTemplate) {
        title = template.name
        selectedType = template.type
        selectedIcon = template.icon
        selectedIconColor = template.color
        source = template.source
        healthKitMetric = template.healthKitMetric

        if template.type == .count {
            goalCountText = String(template.goal)
        } else {
            goalHours = template.goal / 3600
            minutes = (template.goal % 3600) / 60
        }
    }

    func requestHealthKitPermission(using manager: HealthKitManager) {
        guard source == .healthKit, let metric = healthKitMetric else { return }
        Task {
            isRequestingHealthAuth = true
            let types: Set<HKObjectType> = metric == .steps
            ? [HKQuantityType(.stepCount)]
            : [HKCategoryType(.sleepAnalysis)]
            await manager.requestAuthorization(for: types)
            isRequestingHealthAuth = false
        }
    }

    func save(context: ModelContext, existingHabit: Habit?) {
        let config = Habit.Configuration(
            title: title,
            type: selectedType,
            goal: effectiveGoal,
            iconName: selectedIcon,
            iconColor: selectedIconColor,
            activeDays: activeDays,
            reminderTimes: isReminderEnabled ? reminderTimes : nil,
            startDate: startDate,
            source: source,
            healthKitMetric: healthKitMetric
        )

        if let existing = existingHabit {
            print("📝 Попытка ОБНОВЛЕНИЯ привычки: \(title)")
            existing.update(with: config)
        } else {
            print("➕ Попытка СОЗДАНИЯ новой привычки: \(title)")
            let newHabit = Habit(
                title: title,
                type: selectedType,
                goal: effectiveGoal,
                iconName: selectedIcon,
                iconColor: selectedIconColor,
                activeDays: activeDays,
                reminderTimes: isReminderEnabled ? reminderTimes : nil,
                startDate: startDate,
                source: source,
                healthKitMetric: healthKitMetric
            )
            context.insert(newHabit)
        }

        do {
            try context.save()
            print("🚀 УСПЕХ: Данные сохранены в базу без ошибок!")
        } catch {
            print("❌ ОШИБКА сохранения SwiftData: \(error)")
            print("ℹ️ Описание ошибки: \(error.localizedDescription)")
        }
    }
}
