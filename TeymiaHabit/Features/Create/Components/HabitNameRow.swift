import SwiftUI

enum NewHabitField {
    case title
    case count
}

struct HabitNameRow: View {
    @Binding var title: String
    @FocusState.Binding var focus: NewHabitField?

    private let item = NewHabitItem.name

    var body: some View {
        Label {
            HStack {
                TextField(item.title, text: $title)
                    .fontWeight(.medium)
                    .focused($focus, equals: .title)
                    .submitLabel(.next)
                    .onSubmit {
                        focus = .count
                    }

                Button {
                    withAnimation(.smooth) {
                        title = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.appSecondary.opacity(0.5))
                        .font(.system(size: IconSize.sm))
                }
                .buttonStyle(.plain)
                .opacity(title.isEmpty ? 0 : 1)
                .scaleEffect(title.isEmpty ? 0.001 : 1)
                .animation(Animations.spring, value: title.isEmpty)
                .disabled(title.isEmpty)
            }
            .contentShape(.rect)
        } icon: {
            Image(systemName: item.icon)
                .rowIconStyle()
        }
    }
}
