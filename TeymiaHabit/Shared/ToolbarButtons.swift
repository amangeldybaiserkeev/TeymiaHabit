import SwiftUI

struct CloseToolbarButton: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(DS.Colors.primary)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct ConfirmationToolbarButton: ToolbarContent {
    let action: () -> Void
    let isDisabled: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
                action()
            } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.glassProminent)
            .tint(DS.Colors.primary)
            .disabled(isDisabled)
        }
    }
}
