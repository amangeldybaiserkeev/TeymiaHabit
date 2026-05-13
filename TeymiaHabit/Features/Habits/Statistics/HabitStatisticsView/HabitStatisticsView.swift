import SwiftUI

struct HabitStatisticsView: View {
    let habit: Habit
    @Environment(AppDependencyContainer.self) private var appContainer
    @State private var vm: HabitStatisticsViewModel
    @State private var showingLocalPaywall = false

    init(habit: Habit) {
        self.habit = habit
        self._vm = State(wrappedValue: HabitStatisticsViewModel(habit: habit))
    }

    var body: some View {
        @Bindable var vm = vm
        let isPremium = appContainer.storeKitService.isPremium

        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total all time")
                            .foregroundStyle(DS.Colors.primary)

                        Spacer()

                        Text(vm.formattedTotal)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(#colorLiteral(red: 0.9961017966, green: 0.4863132238, blue: 0.1490832567, alpha: 1)), Color(#colorLiteral(red: 0.9961031079, green: 0.2039290071, blue: 0.01577392034, alpha: 1))],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }

                Section {
                    lockedOverlay(isLocked: !isPremium) {
                        MonthlyCalendarView(
                            habit: habit,
                            selectedDate: $vm.selectedDate
                        )
                    }
                }
                .listRowInsets(EdgeInsets())

                Section {
                    lockedOverlay(isLocked: !isPremium) {
                        VStack(spacing: DS.Spacing.md) {
                            TimeRangePicker(selection: $vm.barChartTimeRange)
                            BarChartView(habit: habit, range: vm.barChartTimeRange)
                                .id("\(habit.uuid.uuidString)-\(vm.barChartTimeRange.rawValue)")
                        }
                        .padding(.top, DS.Spacing.reg)
                    }
                } footer: {
                    HStack(spacing: DS.Spacing.xxs) {
                        Image(systemName: "hand.tap")
                        Text("Press and hold bars for details")
                    }
                    .foregroundStyle(DS.Colors.secondary)
                    .padding(.leading, DS.Spacing.reg)
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .toolbar { CloseToolbarButton() }
            .onChange(of: habit.completions) { _, _ in
                vm.refresh()
            }
            .sheet(isPresented: $showingLocalPaywall) {
                PaywallView(storeKitService: appContainer.storeKitService)
            }
        }
    }
}

private extension HabitStatisticsView {
    @ViewBuilder
    func lockedOverlay<Content: View>(isLocked: Bool, @ViewBuilder content: @escaping () -> Content) -> some View {
        if isLocked {
            ZStack {
                content()
                    .blur(radius: 6)
                    .allowsHitTesting(false)

                Button {
                    showingLocalPaywall = true
                } label: {
                    VStack(spacing: DS.Spacing.reg) {
                        PremiumLockBadge(size: DS.IconSize.xxl)

                        Text("Unlock Detailed Statistics")
                            .font(DS.AppFont.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DS.Colors.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, DS.Spacing.lg)
                    .padding(.horizontal, DS.Spacing.xl)
                    .frame(maxWidth: 280)
                    .glassEffect(.regular.interactive(false), in: .rect(cornerRadius: DS.Radius.xl))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DS.Spacing.lg)
            }
        } else {
            content()
        }
    }
}
