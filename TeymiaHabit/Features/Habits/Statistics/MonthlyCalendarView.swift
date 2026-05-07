import SwiftUI
import SwiftData

struct MonthlyCalendarView: View {
    @State private var vm: MonthlyCalendarViewModel
    @Binding var selectedDate: Date

    init(habit: Habit, selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._vm = State(wrappedValue: MonthlyCalendarViewModel(habit: habit))
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
            weekdayHeader
            if !vm.months.isEmpty {
                monthGridContainer
            }
        }
        .padding(.top, DS.Spacing.reg)
        .onAppear {
            vm.setup(selectedDate: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            vm.updateMonthIfNeeded(for: newDate)
        }
        .sheet(item: $vm.detailSheetDate) { date in
            HabitDetailView(habit: vm.habit, date: date, showStatsButton: false)
                .onDisappear {
                    vm.clearDetailSheet()
                }
        }
    }

    // MARK: - Components
    private var headerView: some View {
        StatsPeriodHeader(
            title: DateFormatter.capitalizedNominativeMonthYear(from: vm.currentMonthDate),
            onPrevious: vm.showPreviousMonth,
            onNext: vm.showNextMonth,
            canGoPrevious: vm.canNavigateToPreviousMonth,
            canGoNext: vm.canNavigateToNextMonth,
        )
    }

    private var weekdayHeader: some View {
        WeekdayHeaderView()
            .padding(.horizontal, DS.Spacing.xxs)
            .padding(.bottom, DS.Spacing.reg)
    }

    private var monthGridContainer: some View {
        TabView(selection: $vm.currentMonthIndex) {
            ForEach(vm.months.indices, id: \.self) { index in
                monthGrid(forIndex: index)
                    .frame(height: 310)
                    .tag(index)
                    .drawingGroup()
                    .onAppear {
                        vm.cacheCalendarDays(for: index)
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 310)
        .onAppear {
            vm.generateCalendarDaysIfNeeded(for: vm.currentMonthIndex)
        }
        .onChange(of: vm.currentMonthIndex) { _, newValue in
            vm.handleMonthChange(newIndex: newValue)
        }
    }

    private func monthGrid(forIndex index: Int) -> some View {
        let currentMonth = vm.months[index]
        let allDays: [Date] = vm.getCalendarDays(for: index).flatMap { $0 }.compactMap { $0 }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 7) {
            ForEach(allDays, id: \.self) { (date: Date) in
                let isCurrentMonth = Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                let isBeforeToday = date <= Date()
                let isAfterStart = date >= vm.habit.startDate
                let isActive = vm.habit.isActiveOnDate(date)
                let isFullActive = isCurrentMonth && isBeforeToday && isAfterStart && isActive

                let startOfDay = Calendar.current.startOfDay(for: date)
                let progress = vm.progressCache[startOfDay] ?? vm.habit.completionPercentageForDate(date)

                DayProgressItem(
                    date: date,
                    isSelected: isCurrentMonth && Calendar.current.isDate(selectedDate, inSameDayAs: date),
                    progress: progress,
                    showProgressRing: isFullActive,
                    ringColors: vm.habit.ringColors
                )
                .opacity(isCurrentMonth ? 1.0 : 0.3)
                .grayscale(isCurrentMonth ? 0 : 1.0)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    guard isCurrentMonth && isFullActive else { return }
                    selectedDate = date
                    vm.detailSheetDate = date
                }
            }
        }
        .padding(.horizontal, DS.Spacing.reg)
    }
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}
