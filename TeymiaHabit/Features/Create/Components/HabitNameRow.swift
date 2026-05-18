import SwiftUI

enum NewHabitField {
    case title
    case count
}

struct HabitNameRow: View {
    @Binding var title: String
    @FocusState.Binding var focus: NewHabitField?

    var body: some View {
        Label {
            HStack {
                TextField("Habit name", text: $title)
                    .fontWeight(.medium)
                    .focused($focus, equals: .title)
                    .submitLabel(.next)
                    .onSubmit {
                        focus = .count
                    }

                Button {
                    withAnimation(DS.Animations.spring) {
                        title = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DS.Colors.secondary.opacity(0.5))
                        .font(.system(size: DS.IconSize.sm))
                }
                .buttonStyle(.plain)
                .opacity(title.isEmpty ? 0 : 1)
                .scaleEffect(title.isEmpty ? 0.001 : 1)
                .animation(DS.Animations.spring, value: title.isEmpty)
                .disabled(title.isEmpty)
            }
            .contentShape(.rect)
        } icon: {
            RowIcon(symbol: .habitName)
        }
    }
}

