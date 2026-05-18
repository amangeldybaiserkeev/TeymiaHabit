import SwiftUI
import SwiftData

struct WeeklyCalendarView: View {
    let vm: HabitsViewModel

    @Binding var selectedDate: Date
    @Environment(\.modelContext) private var modelContext

    @Query private var habits: [Habit]
    @Query private var allCompletions: [HabitCompletion]

    @State private var weeks: [[Date]] = []
    @State private var currentWeekIndex: Int = 0
    @State private var availableDateRange: ClosedRange<Date>?
    @State private var refreshID = UUID()

    private var calendar: Calendar { Calendar.userPreferred }

    init(selectedDate: Binding<Date>, vm: HabitsViewModel) {
        self._selectedDate = selectedDate
        self.vm = vm

        let sortDescriptor = SortDescriptor<Habit>(\.createdAt, order: .forward)
        _habits = Query(sort: [sortDescriptor])

        let completionSort = SortDescriptor<HabitCompletion>(\.date, order: .reverse)
        _allCompletions = Query(sort: [completionSort])
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            WeekdayHeaderView()

            TabView(selection: $currentWeekIndex) {
                ForEach(Array(weeks.enumerated()), id: \.element.first) { index, week in
                    weekRow(week: week)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 55)
        }
        .onChange(of: vm.calendarUpdateTrigger) { _, _ in
            refreshID = UUID()
            generateWeeks()
        }
        .onAppear {
            setupCalendar()
        }
        .onChange(of: habits.count) { _, _ in
            setupCalendar()
        }
        .onChange(of: selectedDate) { _, newDate in
            handleSelectedDateChange(newDate)
        }
    }

    private func weekRow(week: [Date]) -> some View {
        HStack(spacing: DS.Spacing.reg) {
            ForEach(week, id: \.self) { date in
                let progress = calculateProgress(for: date)
                let hasHabits = hasActiveHabits(for: date)
                let isAvailable = isDateInAvailableRange(date)
                let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)

                DayProgressItem(
                    date: date,
                    isSelected: isSelected,
                    progress: progress,
                    showProgressRing: hasHabits && isAvailable,
                    isOverallProgress: true
                )
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    handleDateTap(date: date, hasHabits: hasHabits, isAvailable: isAvailable)
                }
            }
        }
        .padding(.horizontal, DS.Spacing.reg)
    }

    // MARK: - Logic

    private func setupCalendar() {
        calculateAvailableDateRange()
        generateWeeks()
        findCurrentWeekIndex()
    }

    private func calculateProgress(for date: Date) -> Double {
        let activeHabits = habits.filter { habit in
            !habit.isArchived && habit.isActiveOnDate(date) && date >= habit.startDate
        }

        guard !activeHabits.isEmpty else { return 0 }

        let totalNormalizedProgress = activeHabits.reduce(0.0) { sum, habit in
            let progressValue = vm.getEffectiveProgress(for: habit, on: date)

            let percentage = habit.goal > 0 ? Double(progressValue) / Double(habit.goal) : 0.0
            return sum + min(percentage, 1.0)
        }

        return totalNormalizedProgress / Double(activeHabits.count)
    }

    private func handleDateTap(date: Date, hasHabits: Bool, isAvailable: Bool) {
        if hasHabits && isAvailable {
            withAnimation(DS.Animations.easeInOut) {
                selectedDate = date
            }
        }
    }

    private func handleSelectedDateChange(_ newDate: Date) {
        if let weekIndex = findWeekIndex(for: newDate), currentWeekIndex != weekIndex {
            withAnimation { currentWeekIndex = weekIndex }
        }
    }

    // MARK: - Helpers

    private func calculateAvailableDateRange() {
        let activeHabits = habits.filter { !$0.isArchived }
        guard !activeHabits.isEmpty else {
            availableDateRange = nil
            return
        }
        let today = Date()
        let earliest = activeHabits.map { $0.startDate }.min() ?? today
        availableDateRange = earliest...today
    }

    private func isDateInAvailableRange(_ date: Date) -> Bool {
        availableDateRange?.contains(date) ?? false
    }

    private func hasActiveHabits(for date: Date) -> Bool {
        habits.contains { !$0.isArchived && $0.isActiveOnDate(date) && date >= $0.startDate }
    }

    private func findCurrentWeekIndex() {
        if let index = findWeekIndex(for: selectedDate) {
            currentWeekIndex = index
        }
    }

    private func findWeekIndex(for date: Date) -> Int? {
        weeks.firstIndex { $0.contains { calendar.isDate($0, inSameDayAs: date) } }
    }

    private var dayHeaders: [String] {
        let weekdays = calendar.shortStandaloneWeekdaySymbols
        let firstDayIndex = calendar.firstWeekday - 1
        let shifted = Array(weekdays[firstDayIndex...] + weekdays[..<firstDayIndex])

        return shifted.map { String($0.prefix(1)) }
    }

    // MARK: - Week Generation

    private func generateWeeks() {
        guard let dateRange = availableDateRange else {
            weeks = []
            return
        }

        let startDate = dateRange.lowerBound
        let endDate = dateRange.upperBound

        var weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)
        guard let weekStart = calendar.date(from: weekStartComponents) else {
            weeks = []
            return
        }

        weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: endDate)
        guard let lastWeekStart = calendar.date(from: weekStartComponents),
              let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: lastWeekStart) else {
            weeks = []
            return
        }

        var generatedWeeks: [[Date]] = []
        var currentWeekStart = weekStart

        while currentWeekStart < weekEnd {
            let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: currentWeekStart) }

            if !weekDates.isEmpty {
                generatedWeeks.append(weekDates)
            }

            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else {
                break
            }

            currentWeekStart = nextWeek
        }

        weeks = generatedWeeks
    }
}

