// File: TeymiaHabit/Views/NewHabit/SubtaskManagementSection.swift
import SwiftUI

/// Eine Sektion zur Verwaltung von Unteraufgaben innerhalb der Gewohnheitserstellung
struct SubtaskManagementSection: View {
    @Binding var subtasks: [SubtaskDraft]
    @State private var newSubtaskTitle: String = ""
    
    var body: some View {
        Section(header: Text("subtasks_header".localized)) {
            // Liste der vorhandenen Unteraufgaben
            // Hinweis:onMove funktioniert in einem Form-ForEach reibungslos
            ForEach($subtasks) { $subtask in
                TextField("subtask_placeholder".localized, text: $subtask.title)
                    .font(.subheadline)
                    .fontDesign(.rounded)
            }
            .onDelete(perform: removeSubtask)
            .onMove(perform: moveSubtask)
            
            // Eingabefeld für neue Unteraufgaben
            HStack {
                TextField("add_subtask_prompt".localized, text: $newSubtaskTitle)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .submitLabel(.done) // FIX: .plus existierte nicht, .done ist korrekt
                    .onSubmit {
                        addSubtask()
                    }
                
                Button(action: addSubtask) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                }
                .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    
    // MARK: - Aktionen
    
    private func addSubtask() {
        let trimmedTitle = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        withAnimation {
            subtasks.append(SubtaskDraft(title: trimmedTitle))
            newSubtaskTitle = ""
        }
    }
    
    private func removeSubtask(at offsets: IndexSet) {
        withAnimation {
            subtasks.remove(atOffsets: offsets)
        }
    }
    
    private func moveSubtask(from source: IndexSet, to destination: Int) {
        withAnimation {
            subtasks.move(fromOffsets: source, toOffset: destination)
        }
    }
}

/// Ein einfacher Entwurf für eine Unteraufgabe, bevor sie als SwiftData-Modell gespeichert wird
struct SubtaskDraft: Identifiable, Equatable {
    let id = UUID()
    var title: String
}

#Preview {
    Form {
        SubtaskManagementSection(subtasks: .constant([
            SubtaskDraft(title: "Erster Schritt"),
            SubtaskDraft(title: "Zweiter Schritt")
        ]))
    }
}
