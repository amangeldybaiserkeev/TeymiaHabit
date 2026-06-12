import SwiftUI

struct HabitStatisticsView: View {
    let habit: Habit
    @Environment(StoreKitService.self) private var storeKitService
    @Environment(\.dismiss) private var dismiss
    @State private var vm: HabitStatisticsViewModel
    @State private var showingPaywall = false

    init(habit: Habit) {
        self.habit = habit
        self._vm = State(wrappedValue: HabitStatisticsViewModel(habit: habit))
    }

    var body: some View {
        @Bindable var vm = vm
        let isPremium = storeKitService.isPremium

        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Total all time")
                            .foregroundStyle(Color.primary)

                        Spacer()

                        Text(vm.formattedTotal)
                            .contentTransition(.numericText())
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
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)

                        lockedOverlay(isLocked: !isPremium) {
                            MonthlyCalendarView(
                                habit: habit,
                                selectedDate: $vm.selectedDate
                            )
                        }
                        .frame(maxWidth: 500)

                        Spacer(minLength: 0)
                    }
                }
                .listRowInsets(EdgeInsets())

                Section {
                    lockedOverlay(isLocked: !isPremium) {
                        VStack(spacing: Spacing.md) {
                            TimeRangePicker(selection: $vm.barChartTimeRange)
                            BarChartView(habit: habit, range: vm.barChartTimeRange)
                                .id("\(habit.uuid.uuidString)-\(vm.barChartTimeRange.rawValue)")
                        }
                        .padding(.top, Spacing.reg)
                    }
                } footer: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "hand.tap")
                        Text("Press and hold bars for details")
                    }
                    .foregroundStyle(Color.secondary)
                    .padding(.leading, Spacing.reg)
                }
                .listRowInsets(EdgeInsets())
            }
            .formStyle(.grouped)
            .navigationTitle(habit.title)
            .navigationSubtitle("Goal: \(habit.formattedGoal)")
            .toolbar { DismissToolbarButton() }
            .onChange(of: habit.completions) { _, _ in
                vm.refresh()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
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
                    showingPaywall = true
                } label: {
                    VStack(spacing: Spacing.reg) {
                        PremiumLockBadge(size: IconSize.xxl)

                        Text("Unlock Detailed Statistics")
                            .font( .headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, Spacing.lg)
                    .padding(.horizontal, Spacing.xl)
                    .frame(maxWidth: 280)
                    .glassEffect(.regular.interactive(false), in: .rect(cornerRadius: Radius.xl))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.lg)
            }
        } else {
            content()
        }
    }
}
