import SwiftUI

struct DayProgressItem: View, Equatable {
    
    let date: Date
    let isSelected: Bool
    let progress: Double
    var showProgressRing: Bool = true
    var ringColors: (dark: Color, light: Color)? = nil
    var isOverallProgress: Bool = false

    var circleSize = DS.IconSize.lg
    var fontSize: CGFloat { circleSize * 0.4 }
    var lineWidth: CGFloat { circleSize * 0.12 }

    private var calendar: Calendar { Calendar.userPreferred }

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    private var isFutureDate: Bool {
        date > Date()
    }

    private var fontWeight: Font.Weight {
        isSelected ? .bold : .regular
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            ZStack {
                if showProgressRing && !isFutureDate {
                    if let colors = ringColors {
                        CalendarProgressRing(
                            progress: progress,
                            ringColors: colors,
                            size: circleSize,
                            lineWidth: lineWidth
                        )
                    } else if isOverallProgress {
                        weeklyCalendarRing
                    }
                }

                Text(dayNumber)
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundStyle(isToday ? .accentColor : DS.Colors.primary)
                    .contentTransition(.numericText())
            }
            .frame(width: circleSize, height: circleSize)

            Circle()
                .fill(isToday ? Color.mandarine : DS.Colors.primary)
                .frame(width: 4, height: 4)
                .opacity(isSelected ? 1 : 0)
        }
    }

    @ViewBuilder
    private var weeklyCalendarRing: some View {
        let isCompleted = progress >= 0.999
        let ringColors: [Color] = isCompleted
        ? [Color(#colorLiteral(red: 0.6274385452, green: 0.8037135005, blue: 0.2274374366, alpha: 1)), Color(#colorLiteral(red: 0.1764799058, green: 0.7451224923, blue: 0.3647513092, alpha: 1))]
        : [Color(#colorLiteral(red: 0.9804754853, green: 0.6000884771, blue: 0.3020181358, alpha: 1)), Color(#colorLiteral(red: 0.9726642966, green: 0.4391923547, blue: 0.2118133008, alpha: 1))]

        ZStack {
            Circle()
                .stroke(DS.Colors.tertiary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: ringColors,
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(DS.Animations.easeInOut, value: progress)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date) &&
        lhs.isSelected == rhs.isSelected &&
        abs(lhs.progress - rhs.progress) < 0.01 &&
        lhs.showProgressRing == rhs.showProgressRing &&
        lhs.isOverallProgress == rhs.isOverallProgress

    }
}

