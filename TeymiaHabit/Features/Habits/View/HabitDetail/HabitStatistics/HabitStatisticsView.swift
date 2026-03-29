import SwiftUI

struct HabitStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var statsViewModel: HabitStatsViewModel
    @Binding var selectedDate: Date
    @Binding var barChartTimeRange: ChartTimeRange
    
    let habit: Habit
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    StreaksView(viewModel: statsViewModel)
                }
                .listRowInsets(EdgeInsets())
                
                Section {
                    MonthlyCalendarView(
                        habit: habit,
                        selectedDate: $selectedDate
                    )
                }
                .listRowInsets(EdgeInsets())
                
                Section {
                    VStack(spacing: 30) {
                        TimeRangePicker(selection: $barChartTimeRange)
                            .padding(.horizontal, 16)
                        
                        barChartContent
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.insetGrouped)
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()
            }
        }
    }
    
    @ViewBuilder
    private var barChartContent: some View {
        switch barChartTimeRange {
        case .week: WeeklyHabitChart(habit: habit)
        case .month: MonthlyHabitChart(habit: habit)
        case .year: YearlyHabitChart(habit: habit)
        }
    }
}
