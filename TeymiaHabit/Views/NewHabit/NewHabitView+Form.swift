//
//  NewHabitView+Form.swift
//  TeymiaHabit
//
//  Created by Julian Schneider on 01.03.26.
//

// File: TeymiaHabit/Views/NewHabit/NewHabitView+Form.swift
import SwiftUI

extension NewHabitView {
    
    @ViewBuilder
    var mainFormContent: some View {
        Form {
            HabitIdentitySection(
                selectedIcon: $selectedIcon,
                selectedColor: $selectedIconColor,
                title: $title
            )
            
            Section {
                ColorPickerSection.forIconPicker(selectedColor: $selectedIconColor)
            }
            .listRowBackground(Color.mainRowBackground)
            .listSectionSpacing(14)
            
            Section {
                IconSection(
                    selectedIcon: $selectedIcon,
                    selectedColor: $selectedIconColor,
                    onShowFullPicker: { showingIconPicker = true }
                )
            }
            .listRowBackground(Color.mainRowBackground)
            
            // Unsere neue, ausgelagerte Komponente für die dynamischen Ziele!
            NewHabitDynamicGoalSection(
                selectedType: $selectedType,
                frequency: $frequency,
                customPeriodStart: $customPeriodStart,
                customPeriodEnd: $customPeriodEnd,
                countGoal: $countGoal,
                hours: $hours,
                minutes: $minutes,
                scheduledTime: $scheduledTime,
                priority: $priority
            )
            
            SubtaskManagementSection(subtasks: $subtasks)
                .listRowBackground(Color.mainRowBackground)
            
            Section {
                StartDateSection(startDate: $startDate)
                
                if frequency == .daily {
                    ActiveDaysSection(activeDays: $activeDays)
                }
                
                ReminderSection(
                    isReminderEnabled: $isReminderEnabled,
                    reminderTimes: $reminderTimes,
                    onShowPaywall: { showPaywall = true }
                )
            }
            .listRowBackground(Color.mainRowBackground)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.mainGroupBackground)
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                guard isFormValid else { return }
                saveHabit()
            } label: {
                Text("button_save".localized)
            }
            .disabled(!isFormValid)
        }
    }
}
