import SwiftUI
import SwiftData

struct MonthlyCalendarView: View {
    // MARK: - Properties
    let habit: Habit

    @Binding var selectedDate: Date
    @Query private var completions: [HabitCompletion]
    @Environment(\.modelContext) private var modelContext

    // MARK: - State
    @State private var months: [Date] = []
    @State private var currentMonthIndex: Int = 0
    @State private var monthCalendarCache: [Int: [[Date?]]] = [:]
    @State private var progressCache: [Date: Double] = [:]
    @State private var tappedDate: Date? = nil
    @State private var detailSheetDate: Date? = nil

    private var calendar: Calendar { Calendar.userPreferred }

    // MARK: - Initialization
    init(habit: Habit, selectedDate: Binding<Date>) {
        self.habit = habit
        self._selectedDate = selectedDate

        let habitId = habit.persistentModelID
        _completions = Query(filter: #Predicate<HabitCompletion> {
            $0.habit?.persistentModelID == habitId
        })
    }

    // MARK: - Body
    var body: some View {
        VStack {
            monthNavigationHeader
            weekdayHeader
            if !months.isEmpty {
                monthGridContainer
            }
        }
        .onAppear(perform: setupCalendar)
        .onChange(of: selectedDate) { _, newDate in
            updateMonthIfNeeded(for: newDate)
        }
        .onChange(of: completions) { _, _ in
            guard detailSheetDate == nil else { return }
            progressCache = [:]
            loadProgressForMonth(at: currentMonthIndex)
        }
        .onChange(of: detailSheetDate) { _, newValue in
            if newValue == nil {
                progressCache = [:]
                loadProgressForMonth(at: currentMonthIndex)
            }
        }
        .sheet(item: $detailSheetDate) { date in
            HabitDetailView(habit: habit, date: date, showStatsButton: false)
        }
    }

    // MARK: - Components
    private var monthNavigationHeader: some View {
        HStack {
            Button(action: showPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        canNavigateToPreviousMonth
                                     ? DS.Colors.primary.gradient
                                     : DS.Colors.primary.opacity(0.5).gradient
                    )
                    .contentShape(.rect)
            }
            .disabled(!canNavigateToPreviousMonth)
            .buttonStyle(.plain)

            Spacer()

            Text(DateFormatter.capitalizedNominativeMonthYear(from: currentMonth))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary.gradient)

            Spacer()

            Button(action: showNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        canNavigateToNextMonth
                        ? DS.Colors.primary.gradient
                        : DS.Colors.primary.opacity(0.5).gradient)
                    .contentShape(.rect)
            }
            .disabled(!canNavigateToNextMonth)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .zIndex(1)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Weekday.orderedByUserPreference, id: \.self) { weekday in
                Text(String(weekday.shortName.prefix(1)).capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.primary.opacity(0.5).gradient)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 16)
    }

    private var monthGridContainer: some View {
        TabView(selection: $currentMonthIndex) {
            ForEach(months.indices, id: \.self) { index in
                monthGrid(forIndex: index)
                    .frame(height: 280)
                    .tag(index)
                    .drawingGroup()
                    .onAppear {
                        cacheCalendarDays(for: index)
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 280)
        .onAppear {
            generateCalendarDaysIfNeeded(for: currentMonthIndex)
        }
        .onChange(of: currentMonthIndex) { _, newValue in
            generateCalendarDaysIfNeeded(for: newValue)
            loadProgressForMonth(at: newValue)
            if newValue > 0 { generateCalendarDaysIfNeeded(for: newValue - 1) }
            if newValue < months.count - 1 { generateCalendarDaysIfNeeded(for: newValue + 1) }
        }
    }

    private func monthGrid(forIndex index: Int) -> some View {
        let allDays: [Date?] = getCalendarDays(for: index).flatMap { $0 }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 7) {
            ForEach(0..<allDays.count, id: \.self) { dayIndex in
                if let date = allDays[dayIndex] {
                    let isBeforeToday = date <= Date()
                    let isAfterStart = date >= habit.startDate
                    let isActive = habit.isActiveOnDate(date)
                    let isFullActive = isBeforeToday && isAfterStart && isActive
                    let startOfDay = calendar.startOfDay(for: date)
                    let progress = progressCache[startOfDay] ?? habit.completionPercentageForDate(date)

                    DayProgressItem(
                        date: date,
                        isSelected: calendar.isDate(selectedDate, inSameDayAs: date),
                        progress: progress,
                        showProgressRing: isFullActive,
                        ringColors: habit.ringColors
                    )
                    .equatable()
                    .frame(width: 40, height: 40)
                    .contentShape(.circle)
                    .onTapGesture {
                        guard isFullActive else { return }
                        selectedDate = date
                        detailSheetDate = date
                    }
                } else {
                    Color.clear.frame(width: 40, height: 40)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Computed Properties

    private var currentMonth: Date {
        guard !months.isEmpty, currentMonthIndex >= 0, currentMonthIndex < months.count else {
            return Date()
        }
        return months[currentMonthIndex]
    }

    private var canNavigateToPreviousMonth: Bool {
        currentMonthIndex > 0
    }

    private var canNavigateToNextMonth: Bool {
        guard !months.isEmpty else { return false }

        let current = calendar.dateComponents([.year, .month], from: Date())
        let displayed = calendar.dateComponents([.year, .month], from: currentMonth)

        let currentYear = current.year ?? 0
        let currentMonthNum = current.month ?? 0
        let displayedYear = displayed.year ?? 0
        let displayedMonthNum = displayed.month ?? 0

        if displayedYear < currentYear {
            return true
        }

        if displayedYear == currentYear {
            return displayedMonthNum < currentMonthNum
        }

        return false
    }

    // MARK: - Setup Methods
    private func setupCalendar() {
        generateMonths()
        findCurrentMonthIndex()
        generateCalendarDaysIfNeeded(for: currentMonthIndex)
        loadProgressForMonth(at: currentMonthIndex)
    }

    private func updateMonthIfNeeded(for newDate: Date) {
        if let monthIndex = findMonthIndex(for: newDate) {
            if monthIndex != currentMonthIndex {
                currentMonthIndex = monthIndex
            }
        }
    }

    // MARK: - Calendar Generation
    private func generateMonths() {
        let today = Date()
        let effectiveStartDate = HistoryLimits.limitStartDate(habit.startDate)

        let startComponents = calendar.dateComponents([.year, .month], from: effectiveStartDate)
        let todayComponents = calendar.dateComponents([.year, .month], from: today)

        guard let startMonth = calendar.date(from: startComponents),
              let currentMonth = calendar.date(from: todayComponents) else {
            months = [today]
            return
        }

        var generatedMonths: [Date] = []
        var currentDate = startMonth

        while currentDate <= currentMonth {
            generatedMonths.append(currentDate)

            guard let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: currentDate) else {
                break
            }
            currentDate = nextMonth
        }

        if generatedMonths.isEmpty {
            generatedMonths = [currentMonth]
        }

        months = generatedMonths
    }

    // Get calendar days for a month (read-only, no state modification)
    private func getCalendarDays(for index: Int) -> [[Date?]] {
        if let cached = monthCalendarCache[index] {
            return cached
        }

        guard index >= 0, index < months.count else {
            return []
        }

        return generateCalendarDays(for: months[index])
    }

    // Save to cache (safe place to modify state)
    private func cacheCalendarDays(for index: Int) {
        guard index >= 0, index < months.count, monthCalendarCache[index] == nil else {
            return
        }

        let days = generateCalendarDays(for: months[index])
        monthCalendarCache[index] = days
    }

    // Check if calendar days need generation
    private func generateCalendarDaysIfNeeded(for index: Int) {
        guard index >= 0, index < months.count, monthCalendarCache[index] == nil else {
            return
        }

        let days = generateCalendarDays(for: months[index])
        monthCalendarCache[index] = days
    }

    private func loadProgressForMonth(at index: Int) {
        let days = getCalendarDays(for: index).flatMap { $0 }.compactMap { $0 }
        for date in days {
            let startOfDay = calendar.startOfDay(for: date)
            progressCache[startOfDay] = habit.completionPercentageForDate(date)
        }
    }

    // MARK: - Progress Loading

    private func generateCalendarDays(for month: Date) -> [[Date?]] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }
        let numDays = range.count

        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        var firstWeekday = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        if firstWeekday < 0 {
            firstWeekday += 7
        }

        var days: [[Date?]] = []
        var week: [Date?] = Array(repeating: nil, count: 7)

        // Fill first week
        for day in 0..<min(7, numDays + firstWeekday) where day >= firstWeekday {
            let dayOffset = day - firstWeekday
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) {
                week[day] = date
            }
        }
        days.append(week)

        // Fill remaining weeks
        let remainingDays = numDays - (7 - firstWeekday)
        let remainingWeeks = (remainingDays + 6) / 7

        for weekNum in 0..<remainingWeeks {
            week = Array(repeating: nil, count: 7)

            for dayOfWeek in 0..<7 {
                let day = 7 - firstWeekday + weekNum * 7 + dayOfWeek + 1
                if day <= numDays {
                    if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                        week[dayOfWeek] = date
                    }
                }
            }

            days.append(week)
        }

        return days
    }

    // MARK: - Helper Methods
    private func findMonthIndex(for date: Date) -> Int? {
        let targetComponents = calendar.dateComponents([.year, .month], from: date)

        for (index, month) in months.enumerated() {
            let monthComponents = calendar.dateComponents([.year, .month], from: month)
            if monthComponents.year == targetComponents.year && monthComponents.month == targetComponents.month {
                return index
            }
        }

        return nil
    }

    private func findCurrentMonthIndex() {
        if let index = findMonthIndex(for: selectedDate) {
            currentMonthIndex = index
        } else if !months.isEmpty {
            currentMonthIndex = months.count - 1
        }
    }

    // MARK: - Navigation Actions
    private func showPreviousMonth() {
        guard canNavigateToPreviousMonth else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonthIndex -= 1
        }
    }

    private func showNextMonth() {
        guard canNavigateToNextMonth else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonthIndex += 1
        }
    }

    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}

