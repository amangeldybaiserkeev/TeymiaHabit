//
//  NewHabitDynamicGoalSection.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Views/NewHabit/NewHabitDynamicGoalSection.swift
import SwiftUI

struct NewHabitDynamicGoalSection: View {
    @Binding var selectedType: HabitType
    @Binding var frequency: HabitFrequency
    @Binding var customPeriodStart: Weekday
    @Binding var customPeriodEnd: Weekday
    @Binding var countGoal: Int
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var scheduledTime: HabitTimeOfDay
    @Binding var priority: HabitPriority
    
    private var goalLabel: String {
        switch frequency {
        case .daily: return String(localized: "Tägliches Ziel", defaultValue: "Tägliches Ziel")
        case .weekly: return String(localized: "Wöchentliches Ziel", defaultValue: "Wöchentliches Ziel")
        case .monthly: return String(localized: "Monatliches Ziel", defaultValue: "Monatliches Ziel")
        case .custom: return String(localized: "Ziel im Zeitraum", defaultValue: "Ziel im Zeitraum")
        }
    }
    
    private var calendar: Calendar { Calendar.userPreferred }
    private var weekdaySymbols: [String] { calendar.orderedFormattedFullWeekdaySymbols }
    private var orderedWeekdays: [Weekday] { Weekday.orderedByUserPreference }
    
    var body: some View {
        Section {
            Picker("Art des Ziels", selection: $selectedType) {
                Text(String(localized: "Anzahl", defaultValue: "Anzahl")).tag(HabitType.count)
                Text(String(localized: "Zeit", defaultValue: "Zeit")).tag(HabitType.time)
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
            
            Picker(selection: $frequency) {
                ForEach(HabitFrequency.allCases, id: \.self) { freq in
                    Text(freq.localizedName).tag(freq)
                }
            } label: {
                Label(String(localized: "Wiederholung", defaultValue: "Wiederholung"), systemImage: "arrow.2.squarepath")
            }
            .pickerStyle(.menu)
            
            if frequency == .custom {
                Picker(selection: $customPeriodStart) {
                    ForEach(Array(orderedWeekdays.enumerated()), id: \.element) { index, day in
                        Text(weekdaySymbols[index]).tag(day)
                    }
                } label: { Text(String(localized: "Start-Tag", defaultValue: "Start-Tag")) }
                
                Picker(selection: $customPeriodEnd) {
                    ForEach(Array(orderedWeekdays.enumerated()), id: \.element) { index, day in
                        Text(weekdaySymbols[index]).tag(day)
                    }
                } label: { Text(String(localized: "End-Tag", defaultValue: "End-Tag")) }
            }
            
            if selectedType == .count {
                Stepper(value: $countGoal, in: 1...999999) {
                    HStack {
                        Text(goalLabel)
                        Spacer()
                        Text("\(countGoal) mal").foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goalLabel)
                    HStack {
                        Picker("Stunden", selection: $hours) { ForEach(0..<24) { h in Text("\(h) h").tag(h) } }
                            .pickerStyle(.wheel).frame(height: 100).clipped()
                        Picker("Minuten", selection: $minutes) { ForEach(0..<60) { m in Text("\(m) m").tag(m) } }
                            .pickerStyle(.wheel).frame(height: 100).clipped()
                    }
                }.padding(.vertical, 4)
            }
            
            Picker(selection: $scheduledTime) {
                ForEach(HabitTimeOfDay.allCases) { time in Label(time.localizedName, systemImage: time.iconName).tag(time) }
            } label: { Label("scheduled_time".localized, systemImage: "clock.fill") }.pickerStyle(.menu)
            
            Picker(selection: $priority) {
                ForEach(HabitPriority.allCases) { p in Label(p.localizedName, systemImage: p.iconName).tag(p) }
            } label: { Label("priority".localized, systemImage: "flag.fill") }.pickerStyle(.menu)
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
